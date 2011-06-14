module S4tUtils

  module_function

  # The return value of prog1 is the _retval_. Before that's returned,
  # though, the _retval_ is yielded to the block. This method is an 
  # alternative to stashing a value in a temporary, fiddling around, then
  # returning the temporary. Here's an example:
  #
  #     prog1(1+1) { | s | puts "Sum is #{s}."}   # => 2
  #
  # The name "prog1" is ancient Lisp jargon.
  def prog1(retval)
    yield(retval)
    retval
  end
  
  # A way of putting debugging statements in code that requires less
  # typing than +puts+.
  #
  #     pi [1, 2, 3], 'input'    # => 'input: [1, 2, 3]
  #
  # The _arg_ is printed using +inspect+. If _leader_ isn't given, 
  # nothing is printed before _arg_. _leader_ can be a string or symbol.
  #
  # pi returns its _arg_, which is occasionally useful for sticking
  # debugging into the middle of complicated expressions.
  def pi(arg, leader=nil)
    leader = leader.to_s if leader
    leader = (leader == nil) ? '' : leader + ': '
    prog1(arg) { puts leader + arg.inspect }
   end
  


  # An ArgForwarder is associated with a _target_. It forwards messages
  # sent to it to the target, passing along any arguments to the method. 
  # So far, so boring. But an ArgForwarder is also created with some 
  # _added_args_. When the ArgForwarder forwards, it prepends those
  # _added_args_ to the message's given arguments.
  #
  #   array = []
  #   forwarder = ArgForwarder.new(array, 5)
  #   forwarder.push
  #   assert_equal([5], array)
  class ArgForwarder
    def initialize(target, *added_args)
      @target = target
      @added_args = added_args
    end

    def method_missing(method, *args) # :nodoc:
      @target.send(method, *(@added_args + args))
    end
  end
end
