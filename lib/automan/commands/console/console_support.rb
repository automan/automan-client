require 'automan/version'
module ConsoleSupport
	def execute_console(options={})
			irb = RUBY_PLATFORM =~ /(:?mswin|mingw)/ ? 'irb.bat' : 'irb'
			
			require 'optparse'
			
			options.merge!(:irb => irb)
			OptionParser.new do |opt|
			  opt.banner = "Usage: console [environment] [options]"
			  opt.on("--irb=[#{irb}]", 'Invoke a different irb.') { |v| options[:irb] = v }
			  opt.on("--debugger", 'Enable ruby-debugging for the console.') { |v| options[:debugger] = v }
			  opt.parse!(ARGV)
			end
			
			libs =  "-r rubygems -r automan/commands/console/required.rb"
			
			if options[:require]
				Array(options[:require]).each{|e|libs << " -r #{e}" }				
			end  
			
			if options[:debugger]
			  begin
			    require 'ruby-debug'
			    libs << " -r ruby-debug"
			    puts "=> Debugger enabled"
			  rescue Exception
			    puts "You need to install ruby-debug to run the console in debugging mode. With gems, use 'gem install ruby-debug'"
			    exit
			  end
			end
			puts "Loading (Automan #{Automan.version})"
			cmd = "#{options[:irb]} #{libs}"
			exec cmd

	end
end