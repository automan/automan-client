#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-08-09.
#  Copyright (c) 2007. All rights reserved.

# See the tutorial for explanations.

require 'pp'
require 'user-choices'

class TutorialExample < UserChoices::Command
  include UserChoices

  def add_sources(builder)
    builder.add_source(CommandLineSource, :usage,
                       "Usage: ruby #{$0} infile")
  end

  def add_choices(builder)
    builder.add_choice(:infile) { | command_line | 
      command_line.uses_arg
    }
  end
  
  def execute
    pp @user_choices
  end
end


if $0 == __FILE__
  S4tUtils.with_pleasant_exceptions do
    TutorialExample.new.execute
  end
end
