require 's4t-utils'
include S4tUtils
require 'enumerator'

require 'user-choices/conversions'
require 'user-choices/sources'

module UserChoices

  # This class accepts a series of source and choice descriptions
  # and then builds a hash-like object that describes all the choices
  # a user has made before (or while) invoking a script.
  class ChoicesBuilder

    def initialize
      @defaults = {}
      @conversions = {}
      @sources = []
    end
    
    # Add the choice named _choice_, a symbol. _args_ is a keyword
    # argument: 
    # * <tt>:default</tt> takes a value that is the default value of the _choice_. 
    # * <tt>:type</tt> can be given an array of valid string values. These are
    #   checked.
    # * <tt>:type</tt> can also be given <tt>:integer</tt>. The value is cast into
    #   an integer. If that's impossible, an exception is raised. 
    # * <tt>:type</tt> can also be given <tt>:boolean</tt>. The value is converted into
    #   +true+ or +false+ (or an exception is raised).
    # * <tt>:type</tt> can also be given <tt>[:string]</tt>. The value
    #   will be an array of strings. For example, "--value a,b,c" will
    #   produce ['a', 'b', 'c'].
    #
    # You might also give <tt>:length => 5</tt> or <tt>:length => 3..4</tt>. (In 
    # this case, a <tt>:type</tt> of <tt>[:string]</tt> is assumed.)
    # 
    # The _block_ is passed a CommandLineSource object. It's used
    # to describe the command line.
    def add_choice(choice, args={}, &block)
      # TODO: does the has_key? actually make a difference?
      @defaults[choice] = args[:default] if args.has_key?(:default)
      @conversions[choice] = []
      Conversion.record_for(args[:type], @conversions[choice])
      if args.has_key?(:length)
        Conversion.record_for({:length => args[:length]}, @conversions[choice])
      end
      block.call(ArgForwarder.new(@command_line_source, choice)) if block
    end

    # This adds a source of choices. The _source_ is a class like
    # CommandLineSource. The <tt>messages_and_args</tt> are sent 
    # to a new object of that class. 
    def add_source(source_class, *messages_and_args)
      source = source_class.new
      message_sends(messages_and_args).each { | send_me | source.send(*send_me) }
      @sources << source
      @command_line_source = source if source_class <= CommandLineSource
    end
    
    # Add a single line composed of _string_ to the current position in the
    # help output.
    def add_help_line(string)
      user_claims(@command_line_source) {
        "Can't use 'add_help_string' when there's no command line source."
      }
      @command_line_source.add_help_line(string)
    end
    
    # Demarcate a section of help text. It begins with the _description_, 
    # ends with a dashed line.
    def section(description)
      add_help_line("... " + description + ":")
      yield
      add_help_line("---------------------------------")
      add_help_line('')
    end
    
    # In groups of related commands, there are often choices that apply to
    # all commands and choices that apply only to this particular command.
    # Use this to define the latter.
    def section_specific_to_script
      section("specific to this script") do
        yield
      end
    end
    
    

    # Once sources and choices have been described, this builds and
    # returns a hash-like object indexed by the choices.
    def build
      retval = {}
      @sources << DefaultSource.new.use_hash(@defaults)
      @sources.each { |s| s.fill }
      @sources.each { |s| s.apply(@conversions) }
      @sources.reverse.each { |s| retval.merge!(s) }
      @sources.each { |s| s.adjust(retval) }
      retval
    end
    
    # Public for testing.
    
    def message_sends(messages_and_args)  # :nodoc: 
      where_at = symbol_indices(messages_and_args)
      where_end = where_at[1..-1] + [messages_and_args.length]
      where_at.to_enum(:each_with_index).collect do |start, where_end_index |
        messages_and_args[start...where_end[where_end_index]]
      end
    end
    
    def symbol_indices(array) # :nodoc: 
      array.to_enum(:each_with_index).collect do |obj, index|
        index if obj.is_a?(Symbol)
      end.compact
    end
  end

end
