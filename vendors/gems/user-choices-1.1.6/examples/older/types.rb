#!/usr/bin/env ruby

require 'pp'
require 'user-choices'
include UserChoices

class TypesExample < Command

  def add_sources(builder)
    builder.add_source(CommandLineSource, :usage,
                       "Usage: ruby #{$0} [options] arg")
  end

  def add_choices(builder)
    # This is how you restrict an option argument to one of a list of
    # strings.
    builder.add_choice(:a_or_b,
                       :type => ['a', 'b']) { | command_line |
      command_line.uses_option("--a-or-b CHOICE",
                               "CHOICE is either 'a' or 'b'")
    }

    # This is how you insist that an option argument be an integer
    # (in string form). If correctly formatted, the string is turned
    # into an integer. Note that the default value can be either a 
    # string or an integer.
    builder.add_choice(:must_be_integer,
                       :default => 0,
                       :type => :integer) { | command_line |
      command_line.uses_option("--must-be-integer INT")
    }

    # This is how to tell the builder that the argument is a
    # comma-separated list of options. The declaration is not required
    # for command lines, or lists in a configuration file. Those are
    # already broken out into their constituent elements in the source
    # text, so the builder doesn't have to split a string at comma
    # boundaries. You can declare the type if you want, though.
    
    builder.add_choice(:option_list, :type => [:string], :length => 2) { | command_line |
      command_line.uses_option("--option-list OPT,OPT",
                               "Comma-separated list of exactly two options.")
    }
                       

    builder.add_choice(:arg) { | command_line |
      command_line.uses_arg
    }
  end

  def execute
    pp @user_choices
  end
end


if $0 == __FILE__
  S4tUtils.with_pleasant_exceptions do
    TypesExample.new.execute
  end
end
