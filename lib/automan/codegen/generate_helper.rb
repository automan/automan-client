module Codegen
  module GenerateHelper 
    class PlainLogger 
     def method_missing(name, *args)
       $stdout.puts name#, args
     end
   end
    # Copy a file from source to destination with collision checking.
    #
    # The file_options hash accepts :chmod and :shebang and :collision options.
    # :chmod sets the permissions of the destination file:
    #   file 'config/empty.log', 'log/test.log', :chmod => 0664
    # :shebang sets the #!/usr/bin/ruby line for scripts
    #   file 'bin/generate.rb', 'script/generate', :chmod => 0755, :shebang => '/usr/bin/env ruby'
    # :collision sets the collision option only for the destination file:
    #   file 'settings/server.yml', 'config/server.yml', :collision => :skip
    #
    # Collisions are handled by checking whether the destination file
    # exists and either skipping the file, forcing overwrite, or asking
    # the user what to do.
    def file(source, destination, file_options = {})
      # Determine full paths for source and destination files.      
      destination_exists  = File.exist?(destination)

      # If source and destination are identical then we're done.
      if destination_exists and identical?(source, destination)
        return logger.identical(destination)
      end

      # Check for and resolve file collisions.
      if destination_exists 

        # Take action based on our choice.  Bail out if we chose to
        # skip the file; otherwise, log our transgression and continue.
        case force_file_collision?(source, destination, file_options)
          when :force then logger.force(destination)
          when :skip  then return(logger.skip(destination))
          else raise "Invalid collision choice: #{choice}.inspect"
        end

      # File doesn't exist so log its unbesmirched creation.
      else
        logger.create destination
      end

      # If we're pretending, back off now.
      return if options[:pretend]

      # Write destination file with optional shebang.  Yield for content
      # if block given so templaters may render the source file.  If a
      # shebang is requested, replace the existing shebang or insert a
      # new one.
      File.open(destination, 'wb') do |dest|
        dest << source
      end

      # Optionally change permissions.
      if file_options[:chmod]
        FileUtils.chmod(file_options[:chmod], destination)
      end

      # Optionally add file to subversion or git
      system("svn add #{destination}") if options[:svn]
      system("git add -v #{destination}") if options[:git]
    end

    # Checks if the source and the destination file are identical. If
    # passed a block then the source file is a template that needs to first
    # be evaluated before being compared to the destination.
    def identical?(source, destination, &block)
      return false if File.directory? destination
      destination = IO.read(destination)
      source == destination
    end          
                               
    def logger
       @logger||= begin
         PlainLogger.new
       end
    end
    
 private
    # Ask the user interactively whether to force collision.
    def force_file_collision?(src, destination, file_options = {}, &block)
    	return :force if options[:collision] == :force
      $stdout.print "overwrite #{destination}? (enter \"h\" for help) [Ynaqh] "			
      case $stdin.gets.chomp
        when /\Aa\z/i                     
          $stdout.puts "forcings"
          options[:collision] = :force
        when /\Aq\z/i
          $stdout.puts "aborting"
          raise SystemExit
        when /\An\z/i then :skip
        when /\Ay\z/i then :force
        else
          $stdout.puts <<-HELP
a - all, overwrite this and all others
y - yes, overwrite
n - no, do not overwrite
q - quit, abort
h - help, show this help
HELP
          raise 'retry'
      end
    rescue
      retry
    end      

  end    
end