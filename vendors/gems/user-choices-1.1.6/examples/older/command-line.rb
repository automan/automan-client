#!/usr/bin/env ruby

require 'pp'
require 'user-choices'

class CommandLineExample < UserChoices::Command

  # The _sources_ are the various places in which the user can
  # describe her choices to the program. In this case, there's
  # only the command line. 

  def add_sources(builder)
    builder.add_source(UserChoices::CommandLineSource, :usage,
                       "Usage: ruby #{$0} [options] names...")
  end

  # Each individual choice is named with a symbol. The block
  # describes the command line options corresponding to the choice, plus
  # any help text for that option. The arguments to uses_options are passed
  # on to OptionParser. 

  def add_choices(builder)
    builder.add_choice(:choice) { | command_line |
      command_line.uses_option("-c", "--choice CHOICE",
                               "CHOICE can be any string.")
    }

    # The argument list to the command is interpreted as another
    # option. In this case, it's a list of strings.
    builder.add_choice(:names) { | command_line |
      command_line.uses_arglist
    }
  end

  # Perform the command.
  def execute
    pp @user_choices
  end
end


if $0 == __FILE__
  S4tUtils.with_pleasant_exceptions do
    CommandLineExample.new.execute
  end
end
