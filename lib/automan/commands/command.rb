require 'automan/commands/helpers'                                 
module Automan
  module Command
    class Base
      include Automan::Helpers
      attr_accessor :args   
      
      def initialize(args)
        @args = args             
      end          
      
      def confirm(message="Are you sure you wish to continue? (y/n)?")
        display("#{message} ", false)
        ask.downcase == 'y'
      end

      def format_date(date)
        date = Time.parse(date) if date.is_a?(String)
        date.strftime("%Y-%m-%d %H:%M %Z")
      end

      def ask
        gets.strip
      end

      def shell(cmd)
        FileUtils.cd(Dir.pwd) {|d| return `#{cmd}`}
      end
      
      def usage
        
      <<-EOTXT
=== Command List:
  automan console (控制台)
  automan create project_name (命令行创建项目)
  automan version (查看版本)
  automan help (帮助) 

EOTXT
    	end
      
    end
    class InvalidCommand < RuntimeError; end
    class CommandFailed  < RuntimeError; end

    class << self
			include Automan::Helpers
      def run(command, args, retries=0)
        begin         
          run_internal(command, args.dup)
        rescue InvalidCommand
          error "Unknown command. Run 'automan help' for usage information."
        rescue CommandFailed => e
          error e.message
        rescue Interrupt => e
          error "\n[canceled]"
        end
      end

      def run_internal(command, args)
        klass, method = parse(command)
        runner = klass.new(args)
        raise InvalidCommand unless runner.respond_to?(method)
        runner.send(method)
      end

      def parse(command)
        parts = command.split(':')
        case parts.size
          when 1
            begin
              return eval("Automan::Command::#{command.capitalize}"), :index
            rescue NameError, NoMethodError
              return Automan::Command::Help, command
            end
          when 2
            begin
              return Automan::Command.const_get(parts[0].capitalize), parts[1]
            rescue NameError
              raise InvalidCommand
            end
          else
            raise InvalidCommand
        end
      end
    end
  end
end

#加载命令行要用到的rb文件
Dir["#{File.dirname(__FILE__)}/*.rb"].each { |c| 
	unless (/_helper\.rb$|command\.rb$/=~c)
		require c 
	end
}