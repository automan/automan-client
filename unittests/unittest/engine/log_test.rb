require File.dirname(__FILE__) + "/../setup"

include AWatir
class LogTests < Test::Unit::TestCase

  def setup
		goto_page("taobao.html")
  end

  def test_find_elements_string_not_in_array
    ie = IEModel.attach(/taobao/)
    m = ie.cast(TaobaoUnitTestPage)
    m.product_list["不存在的元素"].click
  end
  def test_find_elements_index_out_of_range
    ie = IEModel.attach(/taobao/)
    m = ie.cast(TaobaoUnitTestPage)
    c = m.product_list.length
    m.product_list[c+1].click    
  end
  def test_find_models_index_out_of_range
    ie = IEModel.attach(/taobao/)
    m = ie.cast(TaobaoUnitTestPage)
    c = m.product_model.length
    m.product_model[c+1].search_text.set '123'
  end
  def test_find_models_string_not_in_array
    ie = IEModel.attach(/taobao/)
    m = ie.cast(TaobaoUnitTestPage)
    m.product_model["不存在的元素"].search_text.set '123'
  end

  def _test_name_description_not_found
    ie = IEModel.attach(/taobao/)
    m = ie.cast(TaobaoUnitTestPage)
    m.search_text_not_exist.set "abc"
    assert_equal(m.search_text_not_exist.exist?, false)
    m.not_exist_model.not_exist_search.set "test1"
  end

  def _test_name_description_when_find
    ie = IEModel.attach(/taobao/)
    m = ie.cast(TaobaoUnitTestPage)
    m.search_text.set "abc"
    assert_nil(m.search_text.get("nothing"))
    assert_equal(m.search_text.get("title"), "搜索宝贝")
    m.search_model.search_text.set "abc"
  end
  
  def _test_text_field_can_not_find_element
    ie = IEModel.attach(/taobao/)
    m = ie.cast(TaobaoUnitTestPage)
    m.not_exist_model.not_exist_search.set "test3"
    ele = m.not_exist_model.not_exist_search
    ele.set "test4"
  end

  def _test_text_field_can_not_find_model_element
    ie = IEModel.attach(/taobao/)
    m = ie.cast(TaobaoUnitTestPage)
    ele = m.find_element(AWatir::ATextField, "input#q_not_exist", :name=>"only_have_name")
    ele.set "test5"
  end

  def _test_text_field_submodel
    ie = IEModel.attach(/taobao/)
    m = ie.cast(TaobaoUnitTestPage)
    ele = m.search_model.search_text
    ele.set "test2"
  end
  
  def _test_text_field_withindex
    ie = IEModel.attach(/taobao/)
    m = ie.cast(HtmlModel)
    models = m.find_models(HtmlModel, "div.search-panel")
    m = models[0].find_model(HtmlModel, ">.search-input-box")
    ele = m.find_element(AWatir::ATextField, "input#q", :description=>"只有描述，没有名字")
    ele.set "test6"
  end
    
end

class TaobaoUnitTestPage < HtmlModel
  #标准登录
  def search_text
    find_element(AWatir::ATextField, "input#q", :name=>"search_text", :description=>"淘宝首页搜索框")
  end
  #太禅测试用的，不存在的搜索框
  def search_text_not_exist
    find_element(AWatir::ATextField, "input_not_exist#q")
    find_element(AWatir::ATextField, "input_not_exist#q", :name=>"search_text_not_exist", :description=>"太禅测试用的，不存在的搜索框")
  end
  #搜索模型1
  def search_model
    find_model(TaobaoUnitTestSubModel, "div.search-panel", :name=>"search_model", :description=>"搜索模型1")
  end
  #不存在的模型
  def not_exist_model
    find_model(TaobaoUnitTestSubModel, "div.search-panel_not_exist", :name=>"not_exist_model_for_test", :description=>"太禅测试用的，不存在的模型")
  end
  def product_list
    find_elements(AWatir::AElement, "#J_MegaMenu li", :name=>"product_list", :description=>"产品列表")
  end
  def product_model
    find_models(TaobaoUnitTestSubModel, "#J_MegaMenu li", :name=>"product_list", :description=>"产品列表模型")
  end
end
class TaobaoUnitTestSubModel < HtmlModel
  def search_text
    find_element(AWatir::ATextArea, "input#q", :name=>"search_text", :description=>"淘宝首页模型下的搜索框")
  end
  def not_exist_search
    find_element(AWatir::ATextArea, "input#q_not_exist", :name=>"not_exist_search", :description=>"太禅测试用的，淘宝首页模型下的不存在的搜索框")
  end
end