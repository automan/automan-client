module S4tUtils

  def self.on_windows?  # :nodoc:
    Config::CONFIG["arch"] =~ /dos|win32/i
  end

  # Lifted this from Rubygems, which is released under the
  # Ruby license.
  def self.find_home    # :nodoc:
    ['HOME', 'USERPROFILE'].each do |homekey|
      return ENV[homekey] if ENV[homekey]
    end
    if ENV['HOMEDRIVE'] && ENV['HOMEPATH']
      return "#{ENV['HOMEDRIVE']}:#{ENV['HOMEPATH']}"
    end
    begin
      File.expand_path("~")
    rescue StandardError => ex
      if File::ALT_SEPARATOR
        "C:/"
      else
        "/"
      end
    end
  end
  
  # Find and set the paths a test needs to run, given the normal
  # Ruby directory structure. _given_ is something below the test directory.
  # PACKAGE_ROOT becomes the root of 
  # the structure. PACKAGE_ROOT/lib and PACKAGE_ROOT itself are
  # put on the front of the path (the latter is so that 
  # tests can require 'test/something'.
  def set_test_paths(given)
    return if S4tUtils.const_defined?("PACKAGE_ROOT")

    path = File.expand_path(given)
    i = path.index("/test/")
    S4tUtils.const_set("PACKAGE_ROOT", path[0...i])
    $:.unshift("#{PACKAGE_ROOT}/lib")
    $:.unshift("#{PACKAGE_ROOT}")
  end
  module_function :set_test_paths
  
  # If the _given_ file lives as a script inside a typical Ruby development 
  # structure, put ../lib at the front of the path. That includes files
  # from there in preference to old gems lying around. 
  def set_script_lib_path(given) 
    path = File.expand_path(given)
    p = lambda { | x | File.join(File.dirname(path), '..', x) }
    l = p['lib']
    t = p['test']
    s = p['setup.rb']
    $:.unshift(l) if File.exists?(l) && File.exists?(t) && File.exists?(s)
  end
  module_function :set_script_lib_path

end
