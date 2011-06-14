#!/usr/bin/env ruby

require 'pp'
require 'user-choices'

class SwitchExample < UserChoices::Command

  def add_sources(builder)
    builder.add_source(UserChoices::CommandLineSource, :usage,
                       "Usage: ruby #{$0} [options] args...",
                       "There may be 2-4 arguments.")
    
  end

  # Switches are slightly different than options. (The difference is
  # in how they're invoked, as either --switch or --no-switch.) Almost
  # certainly, you want the switch to be of type :boolean and have a
  # default.
  def add_choices(builder)
    builder.add_choice(:switch,
                       :default => false,
                       :type => :boolean) { | command_line |
      command_line.uses_switch("--switch", "-s")
    }

    # You control the allowable length of a choice with the :length
    # keyword argument. It applies to command-line arglists, lists given
    # in configuration files, and the like.
    builder.add_choice(:args, :length => 2..4) { | command_line |
      command_line.uses_arglist
    }
  end

  def execute
    pp @user_choices
  end
end


if $0 == __FILE__
  S4tUtils.with_pleasant_exceptions do
    SwitchExample.new.execute
  end
end
