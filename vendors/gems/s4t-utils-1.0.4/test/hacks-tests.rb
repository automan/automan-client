$:.unshift("../lib")
require 'test/unit'
require 's4t-utils'


class ClaimsTests < Test::Unit::TestCase
  include S4tUtils

  # The name 'prog1' comes from Lisp. Couldn't think of a better one.
  def test_prog1_returns_argument_after_executing_block
    block_result = nil
    prog1_result = prog1(1) {
      block_result = 2
    }
    assert_equal(1, prog1_result)
    assert_equal(2, block_result)
  end

  def test_prog1_is_also_a_module_method
    block_result = nil
    prog1_result = S4tUtils.prog1(1) {
      block_result = 2
    }
    assert_equal(1, prog1_result)
    assert_equal(2, block_result)
  end

  def test_arg_forwarder_forwards_one_arg
    array = []
    forwarder = ArgForwarder.new(array, 5)
    forwarder.push
    assert_equal([5], array)
  end

  def test_arg_forwarder_forwards_multiple_args
    hash = { 1 => 'one', 2 => 'two', 3 => 'three' }
    forwarder = ArgForwarder.new(hash, 1, 2)
    forwarder.values_at
    assert_equal(["one", "two", "three"], forwarder.values_at(3))
  end
  
  def test_pi_prints_to_standard_output_using_inspect
    result = capturing_stdout do
      pi [1, 2, 3], "caption"
    end
    assert_equal("caption: [1, 2, 3]\n", result)
  end

  def test_pi_does_not_need_a_caption
    result = capturing_stdout do
      pi [1, 2, 3]
    end
    assert_equal("[1, 2, 3]\n", result)
  end
  
  def test_pi_can_take_a_symbol_as_a_caption
    result = capturing_stdout do
      pi [1, 2, 3], :caption
    end
    assert_equal("caption: [1, 2, 3]\n", result)    
  end
    
  def test_pi_returns_a_useful_value
    result = capturing_stdout do
      val = pi([1, 2, 3], 'val')
      assert_equal([1, 2, 3], val)
    end
    assert_equal("val: [1, 2, 3]\n", result)
  end
    

end
