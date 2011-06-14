require File.dirname(__FILE__) + "/setup"

class TestLinks < Test::Unit::TestCase
  def test_new_click
    page = start("links1")
    tf = page.find_element(ALink, "#link1")
    tf.click
    assert_match(/Links2-Pass/, IEModel.last_ie.text)
    page.close
  end
end