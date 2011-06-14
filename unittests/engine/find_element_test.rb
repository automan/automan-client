require File.dirname(__FILE__) + "/setup.rb"

class FindElementTest < Test::Unit::TestCase
  def test_find_element
    e = MockModel.root.find_element(MockElement, "*")
    assert_equal(2, e.element)
  end
  def test_find_elements
    es = MockModel.root.find_elements(MockElement, "*")
    assert_equal(MockElement, es[0].class)
    assert_equal(2, es[0].element)
    assert_equal(998, es.length)
  end
  def test_find_button
    e = MockModel.root.find_element(MockButton, "*")
    assert_equal(MockButton, e.class)
    assert_equal(2, e.element)
  end
  def test_find_buttons
    es = MockModel.root.find_elements(MockButton, "*")
    assert_equal(MockButton, es[0].class)
    assert_equal(2, es[0].element)
    assert_equal(998, es.length)
  end
end