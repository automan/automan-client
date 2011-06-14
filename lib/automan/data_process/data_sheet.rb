require 'active_support'
require 'automan/data_process/workbook_parser'
module Automan
  # 供DataDriven使用，提供数据结构，如脚本对应的用例信息等
	class DataSheet
		attr_reader :testcase_records
		
		def self.parse_file(file)
			self.new(Workbook.new(file))
		end
			
		def initialize(workbook)
			@testcase_records = TestcaseRecord.create_many(workbook.sheets["process"])
		ensure 
			workbook.close
		end
		
	end

  # 单个用例的信息，如id，标题，是否执行，执行次数
	class TestcaseRecord
		attr_reader :sheet, :id, :execute, :execute_repeat, :comment, :test_data, :title
		
		def self.create_many(sheet)
			grid = sheet.cell_grid
			if grid.first.size<5
				raise ArugeumentError.new("grid.first.size should bigger than 5, but was #{grid.first.size}")
			end		
			title = grid[0]
			datas  = grid[1..(grid.length)]		
			datas.map{|e|self.new(title, e)}
		end
		
		def initialize(titles, data)
			set_titles(data)
			set_data(titles[5..(titles.length)], data[5..data.length])
		end
		
		private		
		def set_titles(titles)		
			@id = titles[0].to_i
			@title = titles[1]		
			@execute = (titles[2].to_s=~/^y$/i)
			@execute_repeat = [titles[3].to_i,1].max
			@comment = titles[4]		
		end
		
		def set_data(data_titles, data)
			@test_data = data
			#@data = {}
			#data_titles.each_with_index do|title, i|
			#	@data[title] = data[i]
			#end
		end
	end
	
	# excel表
	class Workbook
		attr_accessor :sheets, :path
		def initialize(path)
			@sheets = {}
			@path = File.expand_path(path)
			@parser = WorkbookParser.parse(path)		
			init_sheets("process")	
		end	
		
		def init_sheets(name, options={})
			begin
				@sheets[name] = Sheet.new(self, name)	
			rescue WorkbookParser::SheetNotFound => e
				if !options[:allow_nil]
					puts "Error when reading sheet #{name}, file: #{path}"
				end
			end
		end

		def sheet_rows(name)
			@parser.sheet_rows(name)
		end
		
		def close
			@parser.close
		end
		
	end
		
	class Sheet
		attr_accessor :workbook, :name, :rows
		
		def initialize(workbook, name)
			@workbook = workbook
			@name = name			
			@rows = workbook.sheet_rows(name)
			cell_grid
		end
		
		def cell_grid
			@cell_grid ||= begin
				grid = []
				rows.each do|row|
					grid_row =[]
					row.cells.each{|e|grid_row << e.value}			
					grid << grid_row unless grid_row.first.blank?
				end
				grid
			end
		end 
		
	end
end