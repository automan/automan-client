require 'automan'
def puts(obj)
  AWatir::TestRunLogger.instance.puts(obj)
  STDOUT.puts obj
end