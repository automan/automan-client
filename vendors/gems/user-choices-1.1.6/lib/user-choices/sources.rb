require 'xmlsimple' unless self.class.const_defined?("XmlSimple") # ActiveSupport includes it in /vendor. Grr.
require 'yaml'
require 's4t-utils'
include S4tUtils

require 'user-choices/ruby-extensions'
require 'user-choices/conversions'


module UserChoices   # :nodoc


  # TODO: Right now, elements that are named in a source, but not in an 
  # add_choice() call, nevertheless appear in the final array. Is that good? 
  # Bad? Irrelevant?
  class AbstractSource < Hash # :nodoc:
    
    attr_reader :external_names

    def initialize
      super()
      @external_names = {}
    end

    def source; subclass_responsibility; end

    
    def fill; subclass_responsibility; end
    
    def apply(choice_conversions)
      each_conversion(choice_conversions) do | choice, conversion |
        next unless self.has_key?(choice)
        
        user_claims(conversion.suitable?(self[choice])) {
          error_prefix + bad_look(choice, conversion)
        }
        
        self[choice] = conversion.convert(self[choice])
      end
    end

    def adjust(final_results)
      # Do nothing
    end
    
    def each_conversion(choice_conversion_hash)
      choice_conversion_hash.each do | choice, conversion_list | 
        conversion_list.each do | conversion |
          yield(choice, conversion)
        end
      end
    end


    protected

    def error_prefix
      "Error in #{source}: "
    end
    
    def pretty_value(value)
      case value
      when Array: value.inspect
      else "'#{value}'"
      end
    end

    def bad_look(key, conversion)
      like_what = conversion.description
      "#{@external_names[key]}'s value must be #{like_what}, and #{pretty_value(self[key])} doesn't look right."
    end

  end

  class DefaultSource < AbstractSource   # :nodoc:
    
    def use_hash(defaults)
      @defaults = defaults
      count_symbols_as_external_names(@defaults.keys)
      self
    end
    
    def fill
      merge!(@defaults)
    end

    def source
      "the default values"
    end

    def count_symbols_as_external_names(symbols)
      symbols.each { | symbol |
        # Use inspect so that symbol prints with leading colon
        @external_names[symbol] = symbol.inspect
      }
    end
  end
  DefaultChoices = DefaultSource   # Backward compatibility


  
  # Describe the environment as a source of choices. 
  class EnvironmentSource < AbstractSource
    def fill    # :nodoc:
      @external_names.each { | key, env_var |
        self[key] = ENV[env_var] if ENV.has_key?(env_var)
      }
    end

    # Environment variables beginning with _prefix_ (a string)
    # are considered to be user choices relevant to this script.
    # Everything after the prefix names a choice (that is, a symbol).
    # Dashes are converted to underscores. Examples:
    # * Environment variable <tt>prefix-my-choice</tt> with prefix <tt>"prefix-" is choice <tt>:my_choice</tt>.
    # * Environment variable <tt>PREFIX_FOO</tt> with prefix <tt>"PREFIX_" is choice <tt>:FOO</tt>
    #
    # If you want an array of strings, separate the values by commas:
    # ENV_VAR=a,b,c
    # There's currently no way to escape a comma and no cleverness about
    # quotes or whitespace.
    
    def with_prefix(prefix)
      matches = ENV.collect do | env_var, ignored_value |
        if /^#{prefix}(.+)/ =~ env_var
          [$1.to_inputable_sym, env_var]
        end
      end
      @external_names.merge!(Hash[*matches.compact.flatten])
      self
    end
  
    # Some environment variables have names you don't like. For example, $HOME
    # might be annoying because of the uppercase. Also, if most of your program's 
    # environment variables have some prefix (see with_prefix) but you also want to use
    # $HOME, you need a way to do that. You can satisfy both desires with 
    #
    #      EnvironmentSource.new.with_prefix("my_").mapping(:home => "HOME")
  
    def mapping(map)
      @external_names.merge!(map)
      self
    end
      

    def source    # :nodoc:
      "the environment"
    end
  end
  EnvironmentChoices = EnvironmentSource   # Backward compatibility
  
  
  class FileSource < AbstractSource # :nodoc: 

    def from_file(filename)
      from_complete_path(File.join(S4tUtils.find_home, filename))
    end
    
    def from_complete_path(path)
      @path = path
      @contents_as_hash = self.read_into_hash
      @contents_as_hash.each do | external_name, value |
        sym = external_name.to_inputable_sym
        @external_names[sym] = external_name
      end
      self
    end

    def fill    # :nodoc:
      @external_names.each do | symbol, external_name |
        self[symbol] = @contents_as_hash[external_name]
      end
    end

    def source    # :nodoc:
      "configuration file #{@path}"
    end

    def read_into_hash    # :nodoc:
      return {} unless File.exist?(@path)
      begin
        format_specific_reading
      rescue Exception => ex
        if format_specific_exception?(ex)
          msg = "Badly formatted #{source}: " + format_specific_message(ex)
          ex = ex.class.new(msg)
        end
        raise ex
      end
    end

    protected 
    
    def format_specific_message(ex)
      ex.message
    end
    
    def format_specific_exception_handling(ex); subclass_responsibility; end
    def format_specific_reading; subclass_responsibility; end
  end

  # Use an XML file as a source of choices. The XML file is parsed
  # with <tt>XmlSimple('ForceArray' => false)</tt>. That means that
  # single elements like <home>Mars</home> are read as the value
  # <tt>"Mars"</tt>, whereas <home>Mars</home><home>Venus</home> is
  # read as <tt>["Mars", "Venus"]</tt>.
  class XmlConfigFileSource < FileSource

    # Treat _filename_ as the configuration file. _filename_ is expected
    # to be in the home directory. The home directory is found in the
    # same way Rubygems finds it. (First look in environment variables
    # <tt>$HOME</tt>, <tt>$USERPROFILE</tt>, <tt>$HOMEDRIVE:$HOMEPATH</tt>,
    # file expansion of <tt>"~"</tt> and finally the root.)
    def format_specific_reading
      XmlSimple.xml_in(@path, 'ForceArray' => false)
    end
    
    def format_specific_exception?(ex)
      ex.is_a?(REXML::ParseException)
    end
    
    def format_specific_message(ex)
      ex.continued_exception
    end
      
  end
  XmlConfigFileChoices = XmlConfigFileSource   # Backward compatibility
  
  
  
  
  # Use an YAML file as a source of choices. Note: because the YAML parser
  # can produce something out of many typo-filled YAML files, it's a 
  # good idea to check that your file looks like you'd expect before 
  # trusting in it. Do that with:
  #
  #    irb> require 'yaml'
  #    irb> YAML.load_file('config.yaml')
  #    
  class YamlConfigFileSource < FileSource
    # Treat _filename_ as the configuration file. _filename_ is expected
    # to be in the home directory. The home directory is found in the
    # same way Rubygems finds it. 
    def format_specific_reading
      result = YAML.load_file(@path)
      ensure_hash_values_are_strings(result)
      result
    end

    def format_specific_exception?(ex)
      ex.is_a?(ArgumentError)
    end



    def ensure_hash_values_are_strings(h)
      h.each { |k, v| ensure_element_is_string(h, k) }
    end
    
    def ensure_array_values_are_strings(a)
      a.each_with_index { |elt, index| ensure_element_is_string(a, index) }
    end

    def ensure_element_is_string(collection, key)
      case collection[key]
        when Hash: ensure_hash_values_are_strings(collection[key])
        when Array: ensure_array_values_are_strings(collection[key])
        else collection[key] = collection[key].to_s
      end
    end
      
    
  end
end
