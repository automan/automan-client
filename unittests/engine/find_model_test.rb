require File.dirname(__FILE__) + "/setup.rb"

class FindModelTest < Test::Unit::TestCase
  def test_find_model
    m = MockModel.root.find_model(MockModel, "*")
    assert_equal(2, m.current.element)
  end
  def test_find_models
    ms = MockModel.root.find_models(MockModel, "*")
    assert_equal(MockModel, ms[0].class)
    assert_equal(2, ms[0].current.element)
    assert_equal(998, ms.length)
  end
    def test_find_page
    m = MockModel.root.find_model(MockPage, "*")
    assert_equal(MockPage, m.class)
    assert_equal(2, m.current.element)
  end
  def test_find_pages
    ms = MockModel.root.find_models(MockPage, "*")
    assert_equal(MockPage, ms[0].class)
    assert_equal(2, ms[0].current.element)
    assert_equal(998, ms.length)
  end
  def test_find_models_under_model
    m = MockModel.root.find_model(MockModel, "#id_2")
    mms = m.find_models(MockModel, ">*")
    assert_equal(2,mms.length)
  end
  def test_find_model_under_model
    m = MockModel.root.find_model(MockModel, "#id_2")
    mm = m.find_model(MockModel, "#id_4")
    assert_equal(4, mm.current.element)
  end
end