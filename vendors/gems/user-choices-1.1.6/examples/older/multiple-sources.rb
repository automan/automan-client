#!/usr/bin/env ruby

require 'pp'
require 'user-choices'

class MultipleSourcesExample < UserChoices::Command
  include UserChoices

  # Here are the four sources currently available. 
  #
  # EnvironmentSource is initialized with a prefix. If a choice is
  # named "foo" and the prefix is "ms_", then the value of
  # ENV["ms_foo"] initializes user_choices[:foo].
  #
  # YamlConfigFileSource reads from a given YAML file. The choices in the
  # config file have the same spelling as the choice name (without the
  # colon that makes the choice name a symbol).
  #
  # XmlConfigFileSource reads from a given XML file. The choices in the
  # config file have the same spelling as the choice name (without the
  # colon that makes the choice name a symbol).
  #
  # CommandLineSource uses the command line (including the argument list). 
  # Much of the initialization is done with a block attached to add_choice. 
  #
  # Sources are added in descending order of precedence.

  def add_sources(builder)
    builder.add_source(CommandLineSource, :usage,
                       "Usage: ruby #{$0} [options] names...")
    builder.add_source(EnvironmentSource, :with_prefix, "ms_")
    builder.add_source(YamlConfigFileSource, :from_file, "ms-config.yml")
    builder.add_source(XmlConfigFileSource, :from_file, "ms-config.xml")
  end

  def add_choices(builder)
    builder.add_choice(:ordinary_choice,
                       :default => 'default') { | command_line |
      command_line.uses_option("-o", "--ordinary-choice CHOICE",
                               "CHOICE can be any string.")
    }

    builder.add_choice(:names) { | command_line |
      command_line.uses_arglist
    }
  end

  def execute
    pp @user_choices
  end
end


if $0 == __FILE__
  S4tUtils.with_pleasant_exceptions do
    MultipleSourcesExample.new.execute
  end
end
