module AEngine
  class Selector
    attr_accessor :current;
    #参数elements, 单个或多个BaseElement
    def initialize(elements)
      if(elements.nil?)
        raise ArgumentError.new("elements should not be nil")
      end
      # 是单个的element就直接放Array里了。
      @current= Array(elements)
    end

    def merge(selector)
      self.current.concat selector.current
    end

    # 私有方法

    
    def self.get_parameter(regex, token)
      return regex.match(token).to_a
    end

    # 处理转义字符
    def self.translate(input)
      unless input.nil?
        return input.gsub(/(\\)/, '') #TODO bug here
      end
    end

    def self.get_action(input)
      case input
      when "[element]" then :DoElement
      when "[attribute]" then :DoAttribute
        # content filter [:]
      when "contains" then :DoContentFilter        
      when "empty" then :DoContentFilter
      when "parent" then :DoContentFilter
      when "has" then :DoContentFilter
      when "not" then :DoContentFilter
        #filter [:]
      when "first" then :DoFilter
      when "last" then :DoFilter
      when "even" then :DoFilter
      when "odd" then :DoFilter
      when "eq" then :DoFilter
      when "gt" then :DoFilter
      when "lt" then :DoFilter
        #relative filter [:]
      when "nth-child" then :DoRelativeFilter
      when "first-child" then :DoRelativeFilter
      when "last-child" then :DoRelativeFilter
      when "only-child" then :DoRelativeFilter

      else raise NotImplementedError.new("TODO") #TODO
      end
    end

    def self.DoElement(selector, scope, param)
      element = param[2]

      #TODO update the format
      etype = nil
      if(param[1]=='#')
        etype = :Id
      elsif(param[1]=='.')
        etype = :ClassName
      elsif(element == "*")
        etype = :All
      else
        etype = :ControlName
      end
      
      # filter
      if(scope == :None)
        case etype
        when :Id, :ControlName, :ClassName
          selector.current.delete_if { |e| !e.match_element(element, etype) }
        when :All
          raise StandardError.new("Invalid operation")
        end
        return selector
      else #scope lookup
        list=[]
        case etype
        when :Id then
          selector.current.each { |e| list.concat(e.get_element_by_id(element, scope))   }
        when :ControlName then
          selector.current.each { |e| list.concat(e.get_element_by_control_name(element, scope))   }
        when :ClassName then
          selector.current.each { |e| list.concat(e.get_element_by_class_name(element, scope))   }
        when :All then
          case scope
          when :Descendant then selector.current.each{ |e| list.concat(e.descendant) }
          when :Child then selector.current.each{ |e| list.concat(e.children) }
          when :Next then selector.current.each{ |e| list << e._next }
          when :Siblings then selector.current.each{ |e| list.concat(e.siblings) }
          when :None then
            raise ArgumentError.new("not supported scope #{scope}")
          else
            raise ArgumentError.new("not supported scope #{scope}")
          end
        end
        return Selector.new(list)
      end
    end

    def self.DoFilter(selector, scope, param)
      operation = param[1]
      option = param[2]

      if(selector.current.length > 0)
        case operation
        when "first" then
          selector.current = Array(selector.current.first)
        when "last" then
          selector.current = Array(selector.current.last)
        when "even" then
          result = []
          selector.current.each_with_index { |item,index| result << item if(index%2 == 0) }
          selector.current = result
        when "odd" then
          result = []
          selector.current.each_with_index { |item,index| result << item if(index%2 != 0) }
          selector.current = result
        when "eq" then
          index = Integer(option)
          selector.current = Array(selector.current[index])
        when "gt" then
          index = Integer(option)
          list = selector.current
          selector.current = list.slice(index+1..list.length)
        when "lt" then
          index = Integer(option)
          selector.current = selector.current.slice(0..index-1)
        else
          raise ArgumentError.new("#{operation} 过滤法，不支持")
        end
      end
      return selector
    end

    def self.DoAttribute(selector, scope, param)
      name = param[1]
      operation = param[2]
      value = param[3]
      list = []
      selector.current.each{ |e| list<<e if e.match_attribute(name, operation, value)}
      return Selector.new(list)
    end

    def self.DoContentFilter(selector, scope, param)
      operation = param[1]
      option = param[2]
      list = []
      selector.current.each{ |e| list<<e if(e.match_content(operation, option)) }
      return Selector.new(list)
    end

    def self.DoRelativeFilter(selector, scope, param)
      name = param[1]
      option = param[2]
      list = []
      selector.current.each{ |e| list<<e if (e.find_relatives(name, option)) }
      return Selector.new(list)
    end

    #参数selector, string
    #参数scope, :None :Descendant :Child :Next :Siblings
    def internal_look_up(selector, scope)
      result = self
      tokenizer = Tokenizer.new(selector)
      while(token = tokenizer.next_one)
        param = []
        case token[0].chr
          # hierachy
        when ' ' then scope = :Descendant; next
        when '>' then scope = :Child; next
        when '+' then scope = :Next; next
        when '~' then scope = :Siblings; next
        when ',' then
          result.merge(self.find(tokenizer.selector))
          return result

          # [attribute operation value]
        when '[' then
          param = self.class.get_parameter(Tokenizer.regex_attribute, token)
          param[3] = self.class.translate(param[3])
          action = self.class.get_action("[attribute]")

          # :filter(param)
        when ':' then
          param = self.class.get_parameter(Tokenizer.regex_filter, token)
          param[2] = self.class.translate(param[2])
          action = self.class.get_action(param[1])
          
          # element
        else
          param = self.class.get_parameter(Tokenizer.regex_element, token)
          param[2] = self.class.translate(param[2])
          action = self.class.get_action("[element]")

        end
        if(action)
          result = self.class.send(action, result, scope, param)
          scope = :None
        end
      end
      return result
    end

    def find(selector)
      return internal_look_up(selector, :Descendant)
    end

    class Tokenizer
      @_selector = nil

      def self.create_regex(re)
        return Regexp.new("#{re}$")
      end
      #      private :create_regex
      def self.create_merge_regex(*re)
        return Regexp.new("^(#{re.join("|")})")
      end
      #      private :create_merge_regex
      

      Element_Str = '([#.]?)((?:[\\w_-]|\\\\.)+|\\*)'
      Attribute_Str = '\\[([\\w_-]+)(.*?=)?((?:[^\\\\\\]]|\\\\.)+)?\\]'
      Filter_Str = ':([\\w_-]+)(?:\\(((?:[^\\\\\\)]|\\\\.)+)?\\))?'
      Hierachy_Str = '\\s*[,>+~ ]\\s*'

      Regex_Element = create_regex(Element_Str)
      Regex_Attribute = create_regex(Attribute_Str)
      Regex_Filter = create_regex(Filter_Str)
      
      RE = create_merge_regex(Element_Str, Attribute_Str, Filter_Str, Hierachy_Str)

      def self.regex_element
        Regex_Element
      end
      def self.regex_filter
        Regex_Filter
      end
      def self.regex_attribute
        Regex_Attribute
      end

      #参数selector, string
      def initialize(selector)
        @_selector=selector
        @_position = 0
      end
      def next_one
        if( @_position < @_selector.length)
          str = @_selector.slice(@_position, @_selector.length - @_position)
          m = RE.match(str)
          if(m)
            @_position = @_position + m.to_s.length
            strip = m.to_s.strip
            if strip==""
              return " "
            else
              return strip
            end
          end
        end
        return nil
      end

      def selector
        @_selector.slice(@_position, @_selector.length - @_position)
      end
    end
    #    private :Tokenizer
  end


end