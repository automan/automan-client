module S4tUtils

  module_function

  # A StandardError is thrown if the _fact_ the user claims is true
  # is actually false. The _block_ is called to provide the exception
  # message.
  def user_claims(fact, &block)
    user_is_bewildered(block.call) unless fact
  end

  # A StandardError is thrown if the _fact_ the user disputes is
  # nevertheless true. The _block_ is called to provide the exception
  # message.
  def user_disputes(fact, &block)
    user_claims(!fact, &block)
  end
  alias_method :user_denies, :user_disputes
  
  # An unconditional claim that the user is bewildered by something 
  # that should not have happened. Most usually, it's that the code
  # should never have gotten to this point.
  def user_is_bewildered(msg = "How could this point be reached?")
    raise StandardError.new(msg)
  end
end


