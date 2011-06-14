require File.dirname(__FILE__) + "/setup.rb"

class FindBasicTest < Test::Unit::TestCase
  def test_find_by_id
    e = MockModel.root.find_element(MockElement, "#id_6")
    assert_equal(6, e.element)
  end

  def test_find_by_class
    e = MockModel.root.find_element(MockElement, ".classname_6")
    assert_equal(6, e.element)
  end

  def test_find_by_tag
    e = MockModel.root.find_element(MockElement, "tag_6")
    assert_equal(6, e.element)
  end

  def test_find_by_eq
    e = MockModel.root.find_element(MockElement, "*:eq(0)")
    assert_equal(2, e.element)
  end
  
  def test_find_by_multi_condition
    e = MockModel.root.find_element(MockElement, "tag_6#id_6.classname_6")
    assert_equal(6, e.element)
  end
  
  def test_find_by_parent_child_direct
    e = MockModel.root.find_element(MockElement, ">tag_2")
    assert_equal(2, e.element)
  end
  def test_find_by_parent_child
    e = MockModel.root.find_element(MockElement, "tag_2>tag_4")
    assert_equal(4, e.element)
  end
  def test_find_by_parent_child_fail
    e = MockModel.root.find_element(MockElement, "tag_2>tag_3")
    assert_equal(0, e.element)
  end
  def test_find_by_ancestor_descendant_direct_child
    e = MockModel.root.find_element(MockElement, "tag_2 tag_4")
    assert_equal(4, e.element)
  end
  def test_find_by_ancestor_descendant
    e = MockModel.root.find_element(MockElement, "tag_2 tag_8")
    assert_equal(8, e.element)
  end
  def test_find_by_ancestor_descendant_fail
    e = MockModel.root.find_element(MockElement, "tag_2 tag_3")
    assert_equal(0, e.element)
  end

end