#$:.unshift(File.expand_path(File.join(File.dirname(__FILE__))))

module AWatir

  class Check
    #    class << self
    #      include Test::Unit::Assertions
    #    end
    @@total_warning = 0
    @@warning = 0
    @@op_fail = 0
    @@exception_fail = 0
    @@total_exception_fail = 0
    def self.init(id="Empty", title="Empty")
      @@warning = 0
      @@op_fail = 0
      @@exception_fail = 0
      TestRunLogger.instance.log_result_start(id, title)
    end

    def self.statistic(id="Empty", title="Empty")
      LogInfo.out_statistic(@@warning, @@op_fail)
      result = "Unknown"
      if(@@exception_fail>0)
        result = "SCFail"
      elsif(@@warning>0)
        result = "TCFail"
      else
        result = "Success"
      end
      TestRunLogger.instance.log_result_end(id, title, result, @@warning, @@op_fail)
    end

    def self.add_warning
      @@warning+=1
      @@total_warning+=1
    end
    def self.add_exception_fail
      @@exception_fail += 1
      @@total_exception_fail += 1
    end
    def self.add_op_fail
      @@op_fail = @@op_fail + 1
    end
    def self.total_exception_number
      return @@total_exception_fail
    end
    def self.total_warning_number
      return @@total_warning
    end
    def self.op_fail_number
      return @@op_fail
    end

    def self.warning_number
      return @@warning
    end

    def self.name
      return "基本"
    end

#校验预期值和实际值是否相等
#@param [Object] actual 实际值 expected 预期值  message 备注信息，默认为nil
#@return [Nil]
#@example CheckText.verify_equal("你好", "你好！", "校验页面显示内容是否为“你好”")
    def self.verify_equal(actual, expected, message=nil)
      if actual.eql?(expected)
        LogInfo.out_true_report(name,expected)
      else
        LogInfo.out_false_report(name,actual,expected,message)
        puts caller(1)[0]
        add_warning
        captureWarning
      end
      return nil
    end
    #功能目的:得到方法名
    def self.get_mname
      caller(2)[0]=~/`(.*?)'/  # note the first quote is a backtick
      return $1
    end
    def self.captureWarning
      if Automan.config.capture_warning
        captureDesktopJPG("警告_#{get_mname}")
      end
    end
#校验预期值和实际值是否相等
#@param [Object] actual 实际值 expected 预期值  message 备注信息，默认为nil
#@return [Nil]
#@example CheckText.assert_equal("你好", "你好！", "校验页面显示内容是否为“你好”")
    def self.assert_equal(actual, expected, message=nil)
      if actual.eql?(expected)
        LogInfo.out_true_report(name,expected)
      else
        LogInfo.out_false_report(name,actual,expected,message)
        puts caller(1)[0]
        raise "assert not equal!"
      end
      return nil
    end
#校验表达是是否正确,一旦错误，程序不退出，继续运行
#@param [Object] expression 需要校验的表达式 message 备注信息，默认为nil
#@return [Nil]
#@example CheckText.verify_true(text.include? "你好")
    def self.verify_true(expression,message=nil)
      if expression
        puts "[警告]请勿将对象直接传给本方法，校验控件是否存在请用verify_true(obj.exist?)" if(expression.is_a?(AWatir::AElement))
        puts "#{name}:校验正确"
      else
        puts  "#{name}:校验错误#{message}"
        add_warning
        puts caller(1)[0]
        captureWarning
      end
      return nil
    end
#校验表达是是否正确,一旦错误，程序直接退出
#@param [Object] expression 需要校验的表达式 message 备注信息，默认为nil
#@return [Nil]
#@example CheckText.assert_true(text.include? "你好")
    def self.assert_true(expression,message=nil)
      if expression
        puts "[警告]请勿将对象直接传给本方法，校验控件是否存在请用assert_true(obj.exist?)" if(expression.is_a?(AWatir::AElement))
        puts "#{name}:校验正确"
      else
        puts  "#{name}:校验错误#{message}"
        puts caller(1)[0]
        raise "assert not true!"
      end
    end
#校验表达是是否错误,一旦表达式正确，程序不退出，继续运行
#@param [Object] expression 需要校验的表达式 message 备注信息，默认为nil
#@return [Nil]
#@example CheckText.verify_false(text.include? "你好")
    def self.verify_false(expression,message=nil)
      unless expression
        puts "[警告]请勿将对象直接传给本方法，校验控件是否不存在请用verify_false(obj.exist?)" if(expression.is_a?(AWatir::AElement))
        puts "#{name}:校验正确"
      else
        puts  "#{name}:校验错误#{message}"
        add_warning
        puts caller(1)[0]
        captureWarning
      end
    end
#校验表达是是否正确,一旦错误，程序直接退出
#@param [Object] expression 需要校验的表达式 message 备注信息，默认为nil
#@return [Nil]
#@example CheckText.assert_false(text.include? "你好")
    def self.assert_false(expression,message=nil)
      unless expression
        puts "[警告]请勿将对象直接传给本方法，校验控件是否不存在请用assert_false(obj.exist?)" if(expression.is_a?(AWatir::AElement))
        puts "#{name}:校验正确"
      else
        puts  "#{name}:校验错误#{message}"
        puts caller(1)[0]
        raise "assert not false!"
      end
    end
#校验预期值是否和结果值匹配，一旦不匹配，不退出程序，继续执行下面的代码
#@param [Object] actual 实际值 regxp 预期值支持正则表达式
#@return [Nil]
#@example CheckText.verify_match(text,/你好/)
    def self.verify_match(actual, regxp, message=nil)
      if actual.match regxp
        LogInfo.out_true_report(name,regxp)
      else
        LogInfo.out_false_report(name,actual,regxp,message)
        add_warning
        puts caller(1)[0]
        captureWarning
      end
    end
#校验预期值是否和结果值匹配，一旦不匹配，程序直接退出，不执行下面的代码
#@param [Object] actual 实际值 regxp 预期值支持正则表达式
#@return [Nil]
#@example CheckText.assert_match(text,/你好/)
    def self.assert_match(actual, regxp, message=nil)
      if actual.match regxp
        LogInfo.out_true_report(name,regxp)
      else
        LogInfo.out_false_report(name,actual,regxp,message)
        puts caller(1)[0]
        raise "assert not match!"
      end
    end
    
  end


  class CheckText < Check

    def self.name
      return "文本"
    end
    
  end
  
  class CheckDB < Check

    def self.name
      return "DB"
    end
    
  end
  CheckDb = CheckDB

  class CheckDialog < Check

    def self.name
      return "Dialog"
    end

  end

end

