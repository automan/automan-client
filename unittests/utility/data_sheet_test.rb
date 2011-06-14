require File.dirname(__FILE__)+"/setup"

class TestDataSheetTest < Test::Unit::TestCase
	Automan.config.excel_parser = :ole

	def test_parse_excel_empty1
		excel = read_excel("empty_1")
		assert_equal 1,  excel.testcase_records.size
	end

	def test_parse_excel_2
		excel = read_excel("2")
		assert_equal 2, excel.testcase_records.size
	end
		
	def test_parse_excel_3
    excel = read_excel("3")
    assert_equal 2,  excel.testcase_records.size
	end

	def test_parse_excel_4
		excel = read_excel("4")
		assert_equal 1,  excel.testcase_records.size
	end
	
	def test_parse_excel_sample
		excel = read_excel("sample")
		assert_equal 8,  excel.testcase_records.size
	end
	
	private
	def read_excel(name)
    filepath = File.dirname(__FILE__)+"/excels/#{name}.xls"
		Automan::DataSheet.parse_file(File.expand_path(filepath))
	end
end
