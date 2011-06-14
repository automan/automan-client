#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-08-09.
#  Copyright (c) 2007. All rights reserved.

# See the tutorial for explanations.

require 'pp'
require 'user-choices'

# See the tutorial for explanations.

class TutorialExample < UserChoices::Command
  include UserChoices

  def add_sources(builder)
    builder.add_source(CommandLineSource, :usage,
                       "Usage: ruby #{$0} [options]")
    builder.add_source(EnvironmentSource, :with_prefix, "myprog_")
    builder.add_source(YamlConfigFileSource, :from_file, ".myprog-config.yml")
  end

  def add_choices(builder)
    builder.add_choice(:connections, :type=>:integer, :default=>0) { | command_line |
      command_line.uses_option("-c", "--connections COUNT",
                               "Number of connections to open.")
    }
  end

  def execute
    puts "There are #{@user_choices[:connections]} connections."
    pp @user_choices
  end
end


if $0 == __FILE__
  S4tUtils.with_pleasant_exceptions do
    TutorialExample.new.execute
  end
end
