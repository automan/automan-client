module MockEngineTest
  include AEngine
  #               1
  #             2   3
  #            4 5 6 7
  class MockElement < BaseElement
    def control
      "tag_#{@number}"
    end
    def initialize(number)
      @number = number
    end
    def element
      @number
    end

    def to_s
      @number.to_s
    end
    def children
      arr = []
      arr << self.class.new(@number*2) if(@number*2<1000)
      arr << self.class.new(@number*2+1) if(@number*2+1<1000)
     
      return arr
    end
    def _class
      "classname_#{@number}"
    end
    def id
      "id_#{@number}"
    end
    def parent
      self.class.new(@number/2)
    end
    def _next
      if(@number%2==1)
        return nil
      else
        return self.class.new(@number+1)
      end
    end
    def _text
      "text_#{@number}"
    end
    def get_attribute(name)
      return name.to_s
    end

    @@empty_instance = MockElement.new(0)
    def self.empty
      @@empty_instance
    end
    def empty?
      @number==0
    end
  end
  class MockModel < Model
    def self.root
      MockModel.new(MockElement.new(1), nil, nil)
    end
  end

  class MockButton < MockElement
    
  end
  class MockPage < MockModel
    
  end
end
