require File.dirname(__FILE__) + "/setup"

class TextFieldTests < Test::Unit::TestCase
  def test_new_set_nil
    page = start("textfields1")
    tf = page.find_element(ATextField, "#text2")
    tf.set ""
    assert_equal "", tf.get("value")
    page.close
  end
  def test_new_set_value
    page = start("textfields1")
    tf = page.find_element(ATextField, "*[name=text1]")
    text_value = "ATextField test!"
    tf.set text_value
    assert_equal text_value, tf.get("value")
    page.close
  end
end