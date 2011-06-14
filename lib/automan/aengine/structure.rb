module AEngine
  class Point < Struct.new(:x, :y)
    def +(point)
      return self.class.new(x+point.x,y+point.y)
    end
  end
end