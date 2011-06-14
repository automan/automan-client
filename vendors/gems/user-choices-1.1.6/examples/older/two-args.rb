#!/usr/bin/env ruby

require 'pp'
require 'user-choices'

class TwoArgExample < UserChoices::Command

  def add_sources(builder)
    builder.add_source(UserChoices::CommandLineSource, :usage,
                       "Usage: ruby #{$0} [options] infile outfile")
    
  end

  def add_choices(builder)
    # You can specify an exact number of array elements required.
    builder.add_choice(:args, :length => 2) { | command_line |
      command_line.uses_arglist
    }
  end

  def execute
    pp @user_choices
  end
end


if $0 == __FILE__
  S4tUtils.with_pleasant_exceptions do
    TwoArgExample.new.execute
  end
end
