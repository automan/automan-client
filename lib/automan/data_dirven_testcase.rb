require "data_process/data_sheet"
module Automan
  #进行excel的解析
	class DataDrivenHelper
		attr_reader :sheet		
		def initialize(file)
			@sheet = DataSheet.parse_file(file)
		end

    #进行excel的数据初始化
		def setup
		end
		#进行excel的数据清理
		def teardown		
		end
	end

  # 支持数据驱动的TestBase
	class DataDrivenTestCase
    #加载excel，并运行excel的setup
	  def setup
	  	@helper = nil
      @warning_number = 0
	  	if(file = $0.sub(".rb", ".xls")) && File.file?(file)
	  		@helper = DataDrivenHelper.new(file)
			end
      @helper && @helper.setup
      if defined? setup_db
        raise "setup_db不再支持。请用class_initialize代替setup_db，在class_initialize的代码会在excel数据准备后被调用，一个class里只会调用一次"
      end
	  end

    #执行脚本
	  def test_process
	    if @helper
	      @helper.sheet.testcase_records.each{|testcase_record|
          if(ARGV.length==1) #参数只有一个时，执行不考虑execute参数，直接执行
            if(ARGV.include?(testcase_record.id.to_s))
              puts "用例[#{testcase_record.id}，#{testcase_record.title}]，通过指定ID方式，开始执行。（忽略是否执行字段）"
              run_process(testcase_record)
            end
          else
            if(testcase_record.execute.nil?)
              puts "用例[#{testcase_record.id}，#{testcase_record.title}]，是否执行被设为N，跳过"
            else
              puts "用例[#{testcase_record.id}，#{testcase_record.title}]，开始执行。"
              run_process(testcase_record)
            end
          end
      	}
	    else
	      run_no_xls_process
	    end
	  end

    # 无excel时，执行单个用例
    def run_no_xls_process
      Check.init
      begin
	      process()
      rescue Exception => ex
        _exception_handle(ex)
      end
      Check.statistic      
    end

    # 执行单个用例时，出错处理
    def _exception_handle(ex)
      if(Automan.config.capture_error)
        title = File.basename($0, ".rb").gsub(/[\/:\*\?<>\\]/,'_')
        captureDesktopJPG("错误_#{title}")
      end
      Check.add_exception_fail
      TestRunLogger.instance.log_exception(ex)
    end
    private :_exception_handle

    # 有excel时，执行单个用例
    def run_process(testcase_record)
      Check.init(testcase_record.id, testcase_record.title)      # 在check里进行      TestRunLogger.instance.log_result_start
      begin
        process(*testcase_record.test_data)
      rescue Exception => ex
        _exception_handle(ex)
      end
      Check.statistic(testcase_record.id, testcase_record.title) #在check里进行       TestRunLogger.instance.log_result_end
    end

	  def process(*arg)	    
	  end
    #在运行excel里的delete_sql和init_sql后运行，一个class只运行一次
    def class_initialize
    end
    #在运行excel里的reback_sql前运行，一个class只运行一次
    def class_cleanup
    end

    #运行excel的teardown，并输出结果
	  def teardown
      @helper && @helper.teardown
      if(Check.total_exception_number > 0)
        puts "脚本运行失败，参见错误信息。"
        exit 1
      elsif(Check.total_warning_number > 0)
        puts "脚本运行失败，因为Warning退出，累计Warning#{Check.total_warning_number}次。"
        exit 2
      else
        puts "脚本运行成功。"
      end
	  end

    #处理单个DataDrivenTestcase的子类
	  def run
      TestRunLogger.load_logger
      begin
        setup
        begin
          class_initialize
          test_process
        ensure
          class_cleanup
        end
      rescue Exception => ex
        TestRunLogger.instance.log_init_error(ex)
      ensure
        teardown
      end
    end

    #运行所有的，DataDrivenTestcase的子类
    def self.run_all
      collect_clazz.each{|clazz|clazz.new.run}
    end
	  
    private
    def self.collect_clazz
      result = []
      ::ObjectSpace.each_object(Class) do |klass|
        if (DataDrivenTestCase > klass)
          result << klass
        end
      end
      result
    end
	  
    at_exit do
      unless $!
        DataDrivenTestCase.run_all
      end
    end
	  
  end
  DataDrivenTestcase = DataDrivenTestCase
end

