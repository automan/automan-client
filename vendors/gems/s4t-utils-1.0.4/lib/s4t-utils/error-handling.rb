module S4tUtils

  module_function

  # Typically used to wrap the execution of an entire script. 
  # If an exception is thrown, a terse message is printed (to $stderr)
  # instead of a stack dump. The message printed is gotten from the 
  # exception.
  def with_pleasant_exceptions
    yield
  rescue SystemExit
    raise
  rescue Exception => ex
    $stderr.puts(ex.message)
  end

  # with_pleasant_exceptions swallows the stack trace, which you
  # want to see during debugging. The easy way to see it is to add
  # 'out' to that message, producing this one. To reduce the chance
  # you'll forget to make exceptions pleasant again, a note that 
  # exceptions are turned off is always printed to $stderr.
  def without_pleasant_exceptions
    $stderr.puts "Note: exception handling turned off."
    yield
  end
end
