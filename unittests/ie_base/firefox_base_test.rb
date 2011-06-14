require File.dirname(__FILE__) + "/setup"

class ButtonTest < Test::Unit::TestCase
  def test_check_content   
    page = start("selector")
    eles = page.find_elements(FElement, "a")
    puts eles.inspect
  end
end