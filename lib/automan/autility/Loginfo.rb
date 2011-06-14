#$LOAD_PATH.unshift  File.expand_path(File.join(File.dirname(__FILE__)))

module AWatir

  #写性能日志
  class DebugInfo
    def self.save_descendant(num, time)
      if(num!=0)
        File.open("c:/automan_perf.log", "a") { |file|
          file << "[Desc]数组个数：#{num}\t时间(s)：#{time}\t单个时间(ms)：#{time/num*1000}\r\n"
        }
      end
    end
    def self.save_general_find(time, log_info, element)
      oneline = log_info.selector_history*"|" #竖线隔开
      ele_names=[]
      log_info.action_history.each{|act|
        ele_names << act[:name]
      }
      ele_name = ele_names*"."
      title = element.empty? ? "FndF":"FndS"
      File.open("c:/automan_perf.log", "a") { |file|
        file << "[#{title}]找法：#{oneline}\t时间(s)：#{time}\t名称：#{ele_name}\r\n"
      }
    end
    def self.save_cast(page_type)
      File.open("c:/automan_perf.log", "a") { |file|
        file << "[Cast]转到页面：#{page_type.inspect}\r\n"
      }
    end
    
  end
  
  class LogInfo

=begin rdoc
  函数名称： out_report(check_type,out_state)
  参数说明：
    check_type为校验类型，分为：text,db,dialog,3种
    out_state: 输出状态 true 或 false
  作者： 宝驹
=end
    def self.out_true_report(check_type,check_value)
      check_type_text = get_type(check_type)
      info = "#{check_type_text}： #{check_value}-----校验正确"
      puts info
    end

    def self.out_statistic(warning, op)
      puts "本次运行累计的校验出错次数: #{warning}次"
      puts "本次运行累计的操作失败次数: #{op}次"
    end

    def self.out_false_report(check_type,actual,check_value,message=nil)
      check_type_text = get_type(check_type)
      errorinfo = "#{check_type_text}： #{check_value}-----校验错误"
      puts errorinfo
      result = "#{check_type}实际值：|#{actual}|，预期值为：|#{check_value}|"
      if(actual.class != check_value.class)
        result+=", 实际值类型：#{actual.class}，预期值类型：#{check_value.class}"
      end
      if(message)
        result+=", 其它信息 #{message}"
      end
      puts result
    end

    private
    #将函数名称，转义输入文本
    def self.get_type(check_type)
      case check_type.downcase
      when "基本"
        return "基本"
      when "text"
        return "文本"
      when "db"
        return "DB"
      when "dialog"
        return "Dailog"
      else
        return "文本"
      end
    end    
  end

  class TestRunLogger
    include Singleton

    # 命令行执行方式下的调用方法
    def self.load_logger
      input_hash = {}
      if(ARGV.length==1)
        arg_hash = {}
      else
        arg_hash = Hash[*ARGV]
      end
      input_hash[:jobId]=arg_hash["-jobId"] if arg_hash["-jobId"]
      input_hash[:date]=arg_hash["-date"] if arg_hash["-date"]
      input_hash[:scriptName]=File.basename($0,".rb")
      TestRunLogger.config(input_hash)      
    end
    
    def need_xml_log
      return defined? @@log_file
    end
    # 调用后会新写一个文件，如果已经调过，不会被覆盖。
    def self.config(hash)
      unless defined? @@log_file
        t=Time.now
        init = {:jobId=>(t.seconds_since_midnight).to_i, :date=>t.strftime("%Y-%m-%d"), :scriptName=>"DefaultTestScriptName"}
        hash = init.merge(hash)
      
        job_id = hash[:jobId]
        date = hash[:date]
        script_name = hash[:scriptName]
        @@log_file = "c:/automan/log/#{date}/#{job_id}_#{script_name.gsub(/[\/:\*\?<>\\]/,'_')}.xml"
        path = File.expand_path(File.dirname(@@log_file))
        unless(File.exist?(path))
          FileUtils.mkdir_p(path)
          xsl_file = File.dirname(__FILE__)+"/../resource/CaseReport.xsl"
          FileUtils.copy_file(xsl_file, path+"/CaseReport.xsl")
        end
        
        File.open(@@log_file, "w") { |file|
          file << "<?xml version=\"1.0\" encoding=\"gb2312\" ?>"
          file << "<?xml-stylesheet type=\"text/xsl\" href=\"CaseReport.xsl\"?>"
          file << "<TestRun jobId=\"#{job_id}\" date=\"#{date}\" scriptName=\"#{script_name}\" time=\"#{Time.now}\">"
        }
        @@default_type = "System"
        require 'automan/autility/ExtandPuts'
        puts "XML日志位置：[#{@@log_file}]"
        ObjectSpace::define_finalizer(self.instance, proc{ File.open(@@log_file, "a") { |file| file << "</TestRun>"} })
      end
    end    
    def log_result_start(id, title)      
      File.open(@@log_file, "a") { |file| file << "<TestResult id=\"#{id}\" title=\"#{title}\" type=\"start\" time=\"#{Time.now}\" />"}
    end
    def log_result_end(id, title, result, warning, op_fail)
      if(need_xml_log)
        File.open(@@log_file, "a") { |file| file << "<TestResult id=\"#{id}\" title=\"#{title}\" type=\"end\" result=\"#{result}\" verifyError=\"#{warning}\" operationError=\"#{op_fail}\" time=\"#{Time.now}\" />"}
      else
        return result
      end
    end
    def log_debug_message(str)
      if(need_xml_log)
        File.open(@@log_file, "a") { |file| file << "<Trace type=\"Debug\"><![CDATA[#{str}]]></Trace>"}
        STDOUT.puts str
      else
        return str
      end
    end
    def log_exception(ex)
      AutomanExceptionAnalyser.analyse(ex)
      str = "Error: #{ex} (#{ex.class})."
      File.open(@@log_file, "a") { |file| file << "<Trace type=\"Exception\"><![CDATA[#{str}]]></Trace>"}
      STDOUT.puts str
      arr = ex.backtrace
      str = arr*"\n"
      File.open(@@log_file, "a") { |file| file << "<Trace type=\"BackTrace\"><![CDATA[#{str}]]></Trace>"}
      STDOUT.puts str
    end
    def log_init_error(ex)
      log_exception(ex)
      File.open(@@log_file, "a") { |file| file << "<TestResult id=\"All\" title=\"All\" result=\"NotRun\" verifyError=\"0\" operationError=\"0\" time=\"#{Time.now}\" />"}
    end
    # TestRunLogger.default_type=System
    # TestRunLogger.default_type=User
    def self.default_type=(type)
      @@default_type = type
    end
    #给扩展来调用，以生成xml日志
    def puts(object)
      str = object.to_s
      str = convert_for_html(str)
      File.open(@@log_file, "a") { |file| file << "<Trace type=\"#{@@default_type}\">#{str}</Trace>"}
    end

    private
    def initialize
      if(!defined?(@@log_file) || @@log_file.nil?)
        # 说明不是运行在命令行模式下，什么都不用做
      end
    end
    def convert_for_html(str)
      str = str.gsub("<","&lt;").gsub(">","&gt;").gsub("\\","&#92;")
      return str
    end
  end

  #根据调用栈分析出错原因，会在日志上加[出错分析]的节点
  class AutomanExceptionAnalyser
    #分析错误功能入口
    def self.analyse(ex)
      raise "NotSupported" unless(ex.is_a?(Exception))
      if(message = AutomanExceptionAnalyser._process(ex)) #输出规则
        puts "[出错分析]" + message
      end
    end
    #解析规则
    def self._process(ex)
      rule.each{|r|
        if(r[:class]==ex.class)
          if r[:block_return_true].call(ex)
            result = ""
            result += "[#{r[:error_type]}]" if(r[:error_type])
            result += r[:rule_message].call(ex)
            return result
          end
        end
      }
      return nil
    end
    #规则列表
    def self.rule
      arr = []
      ## NoMethodError, selector_go,
      ## undefined method `selector_go' for [Detail::AuctionDetail::CWangPuDetail::ShopAttachsEmpty Node]:AEngine::ModelArray
      arr << {
        :class=>NoMethodError, #出错源类型
        :block_return_true=>lambda{|ex|
          if(matches = (/^undefined method `#{ex.name}' for (.*)$/).matches(ex.message.gsub("\r\n","")))
            if matches[1].to_s =~ /AEngine::ModelArray/
              return true
            end
          end
          return false
        }, #语句块返回true方能匹配得上
        :rule_message=>lambda{|ex|
          return "你的控件是Submodel Collection，请用[0]或[\"文本\"]方式来定位到某一个Submodel"
        }, #出错打出的信息
        :error_type=>"语法错误" #出错打出的类型
      }
      arr << {
        :class=>NoMethodError,
        :block_return_true=>lambda{|ex|
          if(matches = (/^undefined method `#{ex.name}' for (.*)$/).matches(ex.message.gsub("\r\n","")))
            if matches[1].to_s =~ /AEngine::ElementArray/
              return true
            end
          end
          return false
        },
        :rule_message=>lambda{|ex|
          return "你的控件是Element Collection，请用[0]或[\"文本\"]方式来定位到某一个Element"
        },
        :error_type=>"语法错误"
      }
      return arr
    end
  end
end

