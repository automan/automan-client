module Automan
  # Excel解析
  module WorkbookParser
		SheetNotFound =  Class.new(RuntimeError)
		
		def self.parse(path)
      path = File.expand_path(path)
			parser_sym = Automan.config.excel_parser.to_sym
			case parser_sym
			when :ruby
				WorkbookNativeParser.new(path)
			when :ole
				WorkbookOleParser.new(path)
			else
				raise "Automan.config.excel_parser = #{parser_sym}, not valid"
			end
		end

    #用win32ole来打开excel并读取内容
		class WorkbookOleParser
			PROCESS_NAME = "EXCEL.exe"
			def initialize(path)
				require 'win32ole'
				require "automan/data_process/process_util"
				@killer = Automan::ProcessUtil::Killer.new(PROCESS_NAME)
				@killer.mark do
					@excel_ole = WIN32OLE::new("excel.Application")
					@workbook_ole = @excel_ole.Workbooks.Open(path)
				end
			end
			
			def sheet_rows(sheet_name)
				begin
					sheet_ole = @workbook_ole.Worksheets(sheet_name)							
				rescue WIN32OLERuntimeError => e
					raise SheetNotFound, e.message
				end
				sheet_ole.UsedRange.Rows
			end
			
			def close
				@workbook_ole.Close  #?抽?宸ヤ???
				@excel_ole.Quit()				
				@killer.kill_new_process
			end
		end

    # 使用vendor下的parseexcel来解析excel
		class WorkbookNativeParser			
			def initialize(path)
        require 'parseexcel'
        @excel = Spreadsheet::ParseExcel.parse(path, :encoding => String::GBK)
			end
			
			def sheet_rows(sheet_name)
				sheet = @excel.worksheet(sheet_name, String::GBK)
				raise(SheetNotFound, sheet_name) if sheet.nil?
				parse_rows(sheet)
			end
			
			def close
				
			end
			
			private
			def parse_rows(sheet)					
				row_index = 0
				result = []
				title_size = sheet.row(0)&&sheet.row(0).size
				while !(row = sheet.row(row_index)).to_s.blank?
					row = row.map{|cell|cell.nil? ?	nil	: ( cell.numeric ? cell.to_s : cell.to_s(String::GBK) )}
					row = cut_or_fill_array(row, title_size)
					result <<  row
					row_index+=1
				end
				result.map{|e|RowWrapper.new(e)}
			end
			
			def cut_or_fill_array(array, size)
				assert array.is_a?(Array)
				if (diff = (array.size - size)) > 0
					array[0..size-1 ]
				elsif diff < 0
					array + [nil]*diff.abs
				else
					# do not change
					array
				end
			end
		end
	
		class RowWrapper			
			def initialize(array)
				@array = array
			end
			
			def cells
				@array.map{|e|CellWrapper.new(e)}
			end
		end

		class CellWrapper
			
			def initialize(cell)
				@cell = cell
			end

			def value
				@cell
			end
		end
  end
end