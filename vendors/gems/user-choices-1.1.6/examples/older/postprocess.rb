#!/usr/bin/env ruby

require 'pp'
require 'user-choices'

class ArgNotingCommand < UserChoices::Command

  def add_sources(builder)
    builder.add_source(UserChoices::CommandLineSource, :usage,
                       "Usage: ruby #{$0} [options] infile outfile")
    
  end

  def add_choices(builder)
    builder.add_choice(:args, :length => 2) { | command_line |
      command_line.uses_arglist
    }
  end

  # postprocess_user_choices gives the program the opportunity to
  # do something about choices immediately after they are made. This method
  # runs only once per invocation, whereas the execute() method can 
  # execute several times. This method will often set instance variables. 
  def postprocess_user_choices
    @user_choices[:infile] = @user_choices[:args][0]
    @user_choices[:outfile] = @user_choices[:args][1]
  end

  def execute
    pp @user_choices
  end
end


if $0 == __FILE__
  S4tUtils.with_pleasant_exceptions do
    ArgNotingCommand.new.execute
  end
end
