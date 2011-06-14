require 'optparse'
require 's4t-utils'
require 'user-choices/sources.rb'
require 'user-choices/arglist-strategies'
include S4tUtils

module UserChoices # :nodoc

  # Treat the command line (including the arguments) as a source
  # of choices.
  class CommandLineSource < AbstractSource
    
    def initialize
      super
      @parser = OptionParser.new
      @arglist_handler = NoArguments.new(self)
    end
      
    def source     # :nodoc: 
      "the command line"
    end
    
    # The _usage_lines_ will be used to produce the output from
    # --help (or on error).
    def usage(*usage_lines) 
      help_banner(*usage_lines)
      self
    end
    
    # Called in the case of command-line error or explicit request (--help)
    # to print usage information.
    def help
      $stderr.puts @parser
      exit
    end

    # What we can parse out of the command line

    # Describes how a particular _choice_ is represented on the
    # command line. The _args_ are passed to OptionParser. Each arg
    # will either describe one variant of option (such as <tt>"-s"</tt>
    # or <tt>"--show VALUE"</tt>) or is a line of help text about
    # the option (multiple lines are allowed).
    #
    # If the option takes an array of values, separate the values by commas:
    # --files a,b,c
    # There's currently no way to escape a comma and no cleverness about
    # quotes. 
    def uses_option(choice, *args)
      external_names[choice] = '--' + extract_switch_raw_name(args)
      @parser.on(*args) do | value |
        self[choice] = value
      end
    end

    # A switch is an option that doesn't take a value. A switch
    # described as <tt>"--switch"</tt> has these effects:
    # * If it is not given, the _choice_ is the default value
    #   or is not present in the hash that holds all the choices.
    # * If it is given as <tt>--switch</tt>, the _choice_ has the
    #   value <tt>"true"</tt>. (If the _choice_ was described in
    #   ChoicesBuilder#add_choice as having a <tt>:type => :boolean</tt>,
    #   that value is converted from a string to +true+.)
    # * If it is given as <tt>--no-switch</tt>, the _choice_ has the
    #   value <tt>"false"</tt>.
    def uses_switch(choice, *args)
      external_name = extract_switch_raw_name(args)
      external_names[choice] = '--' + external_name
      args = change_name_to_switch(external_name, args)
      @parser.on(*args) do | value |
        self[choice] = value.to_s
      end
    end

    # Bundle up all non-option and non-switch arguments into an
    # array of strings indexed by _choice_. 
    def uses_arglist(choice)
      use_strategy(choice, ArbitraryArglist)
    end

    # The single argument required argument is turned into
    # a string indexed by _choice_. Any other case is an error.
    def uses_arg(choice)
      use_strategy(choice, OneRequiredArg)
    end

    # If a single argument is present, it (as a string) is the value of
    # _choice_. If no argument is present, _choice_ has no value.
    # Any other case is an error. 
    def uses_optional_arg(choice)
      use_strategy(choice, OneOptionalArg)
    end

    # Add a single line composed of _string_ to the current position in the
    # help output.
    def add_help_line(string)
      @parser.separator(string)
    end


    # Public for testing.

    def fill # :nodoc:
      exit_upon_error do
        remainder = @parser.parse(ARGV)
        @arglist_handler.fill(remainder)
      end
    end
    
    def apply(all_choice_conversions) # :nodoc:
      safely_modifiable_conversions = deep_copy(all_choice_conversions)
      @arglist_handler.claim_conversions(safely_modifiable_conversions)
      
      exit_upon_error do
        @arglist_handler.apply_claimed_conversions
        super(safely_modifiable_conversions)
      end
    end

    def adjust(all_choices) # :nodoc:
      exit_upon_error do
        @arglist_handler.adjust(all_choices)
      end
    end

    def help_banner(banner, *more)    # :nodoc: 
      @parser.banner = banner
      more.each do | line |
        add_help_line(line)
      end
      
      add_help_line ''
      add_help_line 'Options:'

      @parser.on_tail("-?", "-h", "--help", "Show this message.") do
        help
      end
    end

    def deep_copy(conversions) # :nodoc:
      copy = conversions.dup
      copy.each do |k, v|
        copy[k] = v.collect { |conversion| conversion.dup }
      end
    end
    
    def use_strategy(choice, strategy) # :nodoc:
      # The argument list choice probably does not need a name. 
      # (Currently, the name is unused.) But I'll give it one, just 
      # in case, and for debugging.
      external_names[choice] = "the argument list"
      @arglist_handler = strategy.new(self, choice)
    end
    

    def exit_upon_error # :nodoc:
      begin
        yield
      rescue SystemExit
        raise
      rescue Exception => ex
        message = if ex.message.has_exact_prefix?(error_prefix)
                    ex.message
                  else
                    error_prefix + ex.message
                  end
        $stderr.puts(message)
        help
      end
    end



    private
    
    def extract_switch_raw_name(option_descriptions)
      option_descriptions.each do | desc |
        break $1 if /^--([\w-]+)/ =~ desc
      end
    end

    def change_name_to_switch(name, option_descriptions)
      option_descriptions.collect do | desc |
        /^--/ =~ desc ? "--[no-]#{name}" : desc
      end
    end        
  end


  # Process command-line choices according to POSIX rules. Consider
  #
  # ruby copy.rb file1 --odd-file-name
  #
  # Ordinarily, that's permuted so that --odd-file-name is expected to
  # be an option or switch, not an argument. One way to make
  # CommandLineSource parsing treat it as an argument is to use a -- to
  # signal the end of option parsing:
  #
  # ruby copy.rb -- file1 --odd-file-name
  #
  # Another is to rely on the user to set environment variable
  # POSIXLY_CORRECT.
  #
  # Since both of those require the user to do something, they're error-prone. 
  #
  # Another way is to use this class, which obeys POSIX-standard rules. Under
  # those rules, the first word on the command line that does not begin with
  # a dash marks the end of all options. In that case, the first command line
  # above would parse into two arguments and no options.
  class PosixCommandLineSource < CommandLineSource
    def fill
      begin
        already_set = ENV.include?('POSIXLY_CORRECT')
        ENV['POSIXLY_CORRECT'] = 'true' unless already_set
        super
      ensure
        ENV.delete('POSIXLY_CORRECT') unless already_set
      end
    end
  end
end



