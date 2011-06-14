require File.dirname(__FILE__) + "/setup.rb"

class GenTest < Test::Unit::TestCase
  def test_generate_web
    xml_file = File.dirname(__FILE__) + "/web_model.xml"
    ruby_file = File.dirname(__FILE__) + "/web_model.actual.rb"
    output = Codegen::PageModelGenerator.new(xml_file).run
    File.open(ruby_file,"w"){|f|f<<output}

    expect = File.dirname(__FILE__)+"/web_model.expected.rb"
    assert_content_same(expect, ruby_file)
  end
  def test_generate_win
    xml_file = File.dirname(__FILE__) + "/win_model.xml"
    ruby_file = File.dirname(__FILE__) + "/win_model.actual.rb"
    output = Codegen::PageModelGenerator.new(xml_file).run
    File.open(ruby_file,"w"){|f|f<<output}

    expect = File.dirname(__FILE__)+"/win_model.expected.rb"
    assert_content_same(expect, ruby_file)
  end
  

  def assert_content_same(expected_file, actual_file, message=nil)
    expected = File.read(expected_file)
    actual = File.read(actual_file)
    expected_lines = expected.split("\n").select{|e|!e.blank?}
    actual_lines = actual.split("\n").select{|e|!e.blank?}
    assert_equal(expected_lines.size, actual_lines.size )
    expected_lines.each_with_index do|line, index|
      assert_equal_line(line, actual_lines[index])
    end
  end

  def assert_equal_line(expected, actual, message=nil)
    assert_equal expected.gsub(/ |\t|\n/,""), actual.gsub(/ |\t|\n/,""),message
  end
end