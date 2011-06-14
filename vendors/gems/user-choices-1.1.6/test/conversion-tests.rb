#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-08-06.
#  Copyright (c) 2007. All rights reserved.

require 'test/unit'
require 's4t-utils'
require 'user-choices'
include S4tUtils
set_test_paths(__FILE__)


class TestDefaultsAndTypes < Test::Unit::TestCase
  include UserChoices
  
  def test_correct_conversion_objects_are_chosen
    start = []
    Conversion.record_for(:integer, start)
    Conversion.record_for(:boolean, start)
    Conversion.record_for([:string], start)
    Conversion.record_for(["one", "two"], start)
    Conversion.record_for({:length => 1}, start)
    Conversion.record_for({:length => 1..2}, start)
    Conversion.record_for(:string, start)
    
    assert_equal([ConversionToInteger, ConversionToBoolean, 
                  SplittingConversion, ChoiceCheckingConversion,
                  ExactLengthConversion, RangeLengthConversion, NoOpConversion],
                 start.collect { |c| c.class })
  end

  def test_nil_conversion_tags_do_nothing
    start = []
    Conversion.record_for(nil, start)
    assert_equal([], start)
  end

  def test_string_conversion_checking
    nop = Conversion.for(:string)
    assert_true(nop.suitable?("hello"))
    assert_true(nop.suitable?(1))   # Truly does no checking.
    assert_equal('a string', nop.description)
  end

  def test_string_conversion
    nop = Conversion.for(:string)
    assert_equal("12", nop.convert("12"))
  end



  def test_integer_conversion_checking
    c2i = Conversion.for(:integer)
    assert_true(c2i.suitable?("034"))
    assert_false(c2i.suitable?("0x1d"))
    assert_false(c2i.suitable?(["0x1d"]))
    assert_equal('an integer', c2i.description)
  end  
  
  def test_integer_conversion
    c2i = Conversion.for(:integer)
    assert_equal(12, c2i.convert("12"))
  end

  def test_it_is_ok_for_integers_already_to_be_converted
    c2i = Conversion.for(:integer)
    assert_true(c2i.suitable?(12))  
    assert_equal(12, c2i.convert(12))
  end
  


  def test_boolean_conversion_checking
    c2b = Conversion.for(:boolean)
    assert_true(c2b.suitable?("true"))
    assert_true(c2b.suitable?("false"))
    # Case insensitive
    assert_true(c2b.suitable?("False"))
    assert_true(c2b.suitable?("TRUE"))

    assert_false(c2b.suitable?("tru"))
    assert_false(c2b.suitable?(1))
    assert_equal('a boolean', c2b.description)
  end  
  
  def test_boolean_conversion
    c = Conversion.for(:boolean)
    assert_equal(false, c.convert("FalsE"))
    assert_equal(true, c.convert("true"))
  end

  def test_it_is_ok_for_booleans_already_to_be_converted
    c = Conversion.for(:boolean)
    assert_true(c.suitable?(true))  
    assert_equal(false, c.convert(false))
  end
  
  
  
  
  
  def test_any_string_is_accepted_for_splitting_conversion
    s = Conversion.for([:string])
    assert_true(s.suitable?("tru calling"))
    assert_true(s.suitable?("fa,se"))
    assert_false(s.suitable?(1))
  end
  
  def test_splitting
    c = Conversion.for([:string])
    assert_equal(["one"], c.convert("one"))
    assert_equal(["one", "two"], c.convert("one,two"))
    # Whitespace NOT ignored
    assert_equal(["one", " two"], c.convert("one, two"))
  end
  
  def test_it_is_ok_for_values_already_to_be_split
    c = Conversion.for([:string])
    assert_true(c.suitable?(["one", "two"])) 
    assert_equal(["one", "two"], c.convert(["one", "two"]))
  end
  
  
  
  
  def test_choice_checking_conversion
    cc = Conversion.for(["foo", "bar"])
    assert_true(cc.suitable?("foo"))
    assert_true(cc.suitable?("bar"))
    
    assert_false(cc.suitable?("fred"))
    # Case sensitive
    assert_false(cc.suitable?("FOO"))
    assert_equal("one of 'foo' or 'bar'", cc.description)
  end
  
  def test_choice_checking_does_no_conversion
    cc = Conversion.for(["foo", "bar"])
    assert_equal("foo", cc.convert("foo"))
  end
  
  
  def test_length_conversion_with_exact_length
    c = Conversion.for(:length => 1)
    assert_true(c.suitable?([1]))
    assert_false(c.suitable?([]))
    assert_false(c.suitable?([1, 2]))
    assert_false(c.suitable?("not array"))

    assert_equal("of length 1", c.description)
  end
  
  def test_length_conversion_with_exact_length_does_no_conversion
    c = Conversion.for(:length => 1)
    assert_equal(["foo"], c.convert(["foo"]))
  end

  def test_length_conversion_with_range
    c = Conversion.for(:length => 0..1)
    assert_true(c.suitable?([1]))
    assert_true(c.suitable?([]))
    assert_false(c.suitable?([1, 2]))

    assert_equal("a list whose length is in this range: 0..1", c.description)
  end

  def test_length_conversion_with_range_does_no_conversion
    c = Conversion.for(:length => 0..1)
    assert_equal(["foo"], c.convert(["foo"]))
  end
  
end