require File.dirname(__FILE__) + "/setup"

class TextAreaTests < Test::Unit::TestCase
  def test_new_set_nil
    page = start("textarea")
    tf = page.find_element(ATextArea, "#txtMultiLine2")
    tf.set ""
    assert_equal "", tf.text
    page.close
  end
  def test_new_set_value
    page = start("textarea")
    tf = page.find_element(ATextField, "#txtMultiLine1")
    text_value = "test ATextArea based on text_field,test ATextArea based on text_field,test ATextArea based on text_field,"
    tf.set text_value
    assert_equal text_value, tf.text
    page.close
  end
end