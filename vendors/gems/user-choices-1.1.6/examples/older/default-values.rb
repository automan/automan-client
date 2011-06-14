#!/usr/bin/env ruby

require 'pp'
require 'user-choices'

class ArgNotingCommand < UserChoices::Command

  def add_sources(builder)
    builder.add_source(UserChoices::CommandLineSource, :usage,
                       "Usage: ruby #{$0} [options] [name]")
  end

  def add_choices(builder)
    # This example shows how you can specify a default value for an
    # option.
    builder.add_choice(:choice,
                       :default => 'default') { | command_line |
      command_line.uses_option("-c", "--choice CHOICE",
                               "CHOICE can be any string.")
    }

    # uses_optional_arg allows either zero or one arguments. If an
    # argument is given, it is directly the value of user_choices[key]
    # (rather than being stored as a single-element array).
    builder.add_choice(:name) { | command_line |
      command_line.uses_optional_arg
    }
  end

  # Perform the command.
  def execute
    pp @user_choices
  end
end


if $0 == __FILE__
  S4tUtils.with_pleasant_exceptions do
    ArgNotingCommand.new.execute
  end
end
