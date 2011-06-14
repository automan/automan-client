require 'automan/commands/console/console_support.rb'
module Automan::Command
  class Console < Base                   
		include ConsoleSupport
    def index
    	req = ["automan/commands/console_helper.rb"]
			execute_console(:require => req )
    end

  end
end