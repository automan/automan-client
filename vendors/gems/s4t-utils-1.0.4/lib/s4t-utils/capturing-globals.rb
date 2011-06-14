require 'stringio'

module S4tUtils

  module_function

  # Run the block, capturing output to $stderr in a string.
  # That string is the method's return value.
  def capturing_stderr
    old_stderr = $stderr
    new_stderr = StringIO.new
    begin
      $stderr = new_stderr
      yield
    ensure
      $stderr = old_stderr
    end
    new_stderr.string
  end
  
  # Run the block, capturing output to $stdout in a string.
  # That string is the method's return value.
  #
  # Note: this assigns to $stdout, which is deprecated in 
  # favor of $stdout.reopen. However, reopen can't take a 
  # StringIO as an argument.
  def capturing_stdout
    new_stdout = StringIO.new
    $stdout = new_stdout
    begin
      yield
    ensure
      $stdout = STDOUT
    end
    new_stdout.string
  end

  # Run the block, replacing the values of environment variables
  # with the values given in the hash _settings_. The environment
  # variables are restored when the method returns.
  def with_environment_vars(settings)
    begin
      old = {}
      settings.each { | key, value |
        old[key] = ENV[key]
        ENV[key] = value
      }
      yield
    ensure
      settings.each_key { | key |
        ENV[key] = old[key]
      }
    end
  end

  # Run the block with the _HOME_ environment variable set to the 
  # current working directory.
  def with_home_right_here
    begin
      old_home = ENV['HOME']
      ENV['HOME'] = '.'
      yield
    ensure
      ENV['HOME'] = old_home
    end
  end

  # Run the block with the given _file_ (named by a string) deleted before
  # and after.
  def erasing_local_config_file(file)
    with_home_right_here { 
      begin
        File.delete(file) if File.exist?(file)
        yield
      ensure
        File.delete(file) if File.exist?(file)
      end
    }
  end

  # Run the block. During the execution, the contents of _file_ (named by 
  # a string) is replaced with _contents_.
  def with_local_config_file(file, contents)
    erasing_local_config_file(file) do
      File.open(file, 'w') do | io |
        io.puts(contents.to_s)
      end
      yield
    end
  end

  # Run the block. During execution, _ARGV_'s is set as if the 
  # script had been executed with _string_ as its argument list.
  # If the block tries to exit, with_command_args will instead throw
  # a StandardError.
  def with_command_args(string)
    begin
      old_argv = ARGV.dup
      ARGV.replace(string.split)
      yield
    rescue SystemExit => ex
      replacement = StandardError.new(ex.message)
      replacement.set_backtrace(ex.backtrace)
      raise replacement
    ensure
      ARGV.replace(old_argv)
    end
  end
  
  def with_stdin(string)
    old_stdin = $stdin
    $stdin = StringIO.new(string)
    yield
  ensure
    $stdin = old_stdin
  end
    
  

end
