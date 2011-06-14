module Automan
	# 进程处理相关。
  class ProcessUtil

		class << self
      def plist(options=nil)
        ole_result = mgm_service.ExecQuery("Select * from Win32_process")
        result = []
        if options&&!options.values.compact.empty?
          opt = options.to_a.first
          ole_result.each{|e|
            if e.send(opt[0]).downcase == opt[1].downcase
              result << e
            end
          }
        else
          ole_result.each{|e|result<<e}
        end
        result
      end
			 
      def kill_process(process,sleep_time=1)
        process.terminate
        sleep(sleep_time) if sleep_time&&sleep_time>0
      end
				
      def mgm_service
        @mgm_service ||= WIN32OLE.connect('winmgmts:\\\\.')
      end
	  end	

    #用于杀掉无法关闭的进程
	  class Killer
	  	attr_reader :name
			def initialize(process_name)
				@name = process_name
			end

      #列出在block中打开的进程
			def mark(&block)
				@before_plist = plist
				yield
				@after_plist = plist
			end
			
			def kill_new_process
				(@after_plist - @before_plist).each{|e|Automan::ProcessUtil.kill_process(e)}
			end
			
			private
			def plist
				Automan::ProcessUtil.plist(:name => name)
			end
			
		end
  end
end