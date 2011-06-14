#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-08-10.
#  Copyright (c) 2007. All rights reserved.

require 'user-choices/ruby-extensions'

module UserChoices # :nodoc:
  
  # Arglists cause complications, mainly because a command's arglist is 
  # never optional. If you ever want it to be ignored, for example, you have to treat it
  # specially. An AbstractArglistStrategy is a sequence of messages that can 
  # cope with those sort of complications. These messages are called at the 
  # appropriate time by a CommandLineSource. 
  #
  # * <b>AbstractArglistStrategy#fill</b> takes the arglist and converts it to 
  #   the value of some choice symbol. The name should remind you of AbstractSource#fill.
  # * There may be conversions that make sense for values (for this choice symbol) when 
  #   those values do <i>not</i> come from an arglist, but not when they do. 
  #   <b>AbstractArglistStrategy#claim_conversions</b> squirrels them away to protect
  #   them from more generic processing. They are then specially processed by 
  #   AbstractArglistStrategy#apply_claimed_conversions.
  # * After conversions, there may still be work to do. There may be some special
  #   reconciling required to the entire collection of choices. (The final result
  #   may depend on what value the arglist provided and what value some other source 
  #   provided.) <b>AbstractArglistStrategy#adjust</b> does that work.
  class AbstractArglistStrategy # :nodoc:
    
    attr_reader :choice
    
    # A strategy applies an argument list named _choice_ that is a key 
    # in the <i>value_holder</i>. It's hackish, but don't give the _choice_ in 
    # the case where there should be no arglist (and thus no choice symbol to 
    # attach it to).
    def initialize(value_holder, choice=nil)
      @value_holder = value_holder
      @choice = choice
    end
    
    # This method takes the argument list, an array, and puts it into 
    # the <code>value_holder</code>. 
    def fill(arglist); subclass_responsibility; end
    
    # Given _conversions_map_, a list of Conversion, select which apply to the arglist,
    # removing them from the hash.
    def claim_conversions(conversions_map) 
      @claimed_conversions = []
    end
    
    # Apply the claimed conversions to the value previously stored in claim_conversions.
    def apply_claimed_conversions
      # None claimed by default
    end
      
    # Apply any effects of changes to the arglist to the result for all the choices. 
    def adjust(all_choices)
      # By default, do nothing.
    end

    # public for testing.
    def arglist_arity_error(length, arglist_arity) # :nodoc:
      plural = length==1 ? '' : 's'
      expected = case arglist_arity
        when Integer
          arglist_arity.to_s
        when Range
          if arglist_arity.end == arglist_arity.begin.succ
            "#{arglist_arity.begin} or #{arglist_arity.end}"
          else
            arglist_arity.in_words
          end
        else
          arglist_arity.inspect
        end
      "#{length} argument#{plural} given, #{expected} expected."
    end
    

    protected
    
    def claim_length_check(conversions_map)
      @length_check = conversions_map[@choice].find { |c| c.does_length_check? }
      if @length_check
        conversions_map[@choice].reject { |c| c.does_length_check? }
      end
    end

    
  end
  
  # An AbstractArglistStrategy that rejects any non-empty arglist.
  class NoArguments < AbstractArglistStrategy # :nodoc:
    def fill(arglist)
      user_claims(arglist.length == 0) do
        "No arguments are allowed."
      end
    end
    
  end
  
  # The arglist is to be treated as a list, possibly with a Conversion that
  # limits its length. It defers processing of an empty arglist until the 
  # last possible moment and only does it if there's no other value for the
  # choice symbol.
  class ArbitraryArglist < AbstractArglistStrategy # :nodoc:
    def fill(arglist)
      @value_holder[@choice] = arglist unless arglist.empty?
    end
    
    def claim_conversions(conversions_map)
      claim_length_check(conversions_map)
    end
    
    def apply_claimed_conversions
      apply_length_check
    end
      
    def adjust(all_choices)
      return if @value_holder[@choice]
      return if all_choices.has_key?(@choice)
      
      all_choices[@choice] = []
      @value_holder[@choice] = all_choices[@choice]
      apply_length_check
    end

    private
    
    def apply_length_check
      return unless @length_check
      return unless @value_holder[@choice]
      
      value = @value_holder[@choice]
      user_claims(@length_check.suitable?(value)) {
        arglist_arity_error(value.length, @length_check.required_length)
      }
    end
  end
  
  # General handling for cases where the Arglist isn't treated as a list, but
  # rather as a single (possibly optional) element. Subclasses handle the 
  # optional/non-optional case.
  class NonListStrategy < AbstractArglistStrategy # :nodoc:
    def arity; subclass_responsibility; end
    
    def fill(arglist)
      case arglist.length
      when 0: # This is not considered an error because another source
              # might fill in the value.
      when 1: @value_holder[@choice] = arglist[0]
      else user_is_bewildered(arglist_arity_error(arglist.length, self.arity))
      end
    end
    
    def claim_conversions(conversions_map)
      claim_length_check(conversions_map)
      user_denies(@length_check) {
        "Don't specify the length of an argument list when it's not treated as an array."
      }
    end
  end
    
  
  class OneRequiredArg < NonListStrategy   # :nodoc:
    def arity; 1; end
    
    def adjust(all_choices)
      return if all_choices.has_key?(@choice)
      user_is_bewildered(arglist_arity_error(0,1))
    end
    
  end
  
  class OneOptionalArg < NonListStrategy # :nodoc:
    def arity; 0..1; end
  end

end