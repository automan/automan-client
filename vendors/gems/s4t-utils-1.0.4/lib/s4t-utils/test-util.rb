
module S4tUtils
  module TestUtil # :nodoc:

    module_function

    def script(name)
      File.join(PACKAGE_ROOT, 'bin', name)
    end
    
    def test(filename)
      File.join(PACKAGE_ROOT, 'test', filename)
    end
    
    def test_data(filename)
      File.join(PACKAGE_ROOT, 'test', 'data', filename)
    end
  end
end
