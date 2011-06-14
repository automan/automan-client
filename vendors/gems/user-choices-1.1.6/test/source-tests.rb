require 'test/unit'
require 's4t-utils'
require 'builder'
require 'user-choices'
include S4tUtils
set_test_paths(__FILE__)
require 'tempfile'


# The general contract of these objects.
class TestAbstractSource < Test::Unit::TestCase
  include UserChoices
  
  class SubHash < UserChoices::AbstractSource

    # New never takes arguments. Class-specific initialization is done
    # with an appropriately-named method.
    # 
    # That method must return self and set up the external_name hash 
    # so that all symbols handled by this object can be given an external
    # name.
    def only_symbol(symbol, external_name, value)
      @external_names[symbol] = external_name
      @symbol = symbol
      @value = value
      self
    end
    
    # After fill(), values have been read, but not checked.
    def fill; self[@symbol] = @value; end
    
    def source; "the test hash"; end
    
  end

  def test_specific_initializer_notes_external_names
    sh = SubHash.new.only_symbol(:sym, "name", "val")
    assert_equal('name', sh.external_names[:sym])
  end

  def test_filling_sets_values
    sh = SubHash.new.only_symbol(:sym, "name", "val")
    sh.fill
    assert_equal('val', sh[:sym])
  end
  
  def test_will_do_conversion_when_told
    sh = SubHash.new.only_symbol(:sym, "name", "1")
    sh.fill
    
    conversions = { :sym => [Conversion.for(:integer)] }
    sh.apply(conversions)
    assert_equal(1, sh[:sym])
  end
  
  # Checking - really just want to know that the error message comes out right.
  
  def test_will_do_integer_error_checking_when_told
    sh = SubHash.new.only_symbol(:sym, "name", "val")
    sh.fill

    conversions = { :sym => [Conversion.for(:integer)] }
    assert_raises_with_matching_message(StandardError,
            /^Error in the test hash: name's value must be an integer, and 'val' doesn't look right/) {
      sh.apply(conversions)
    }
  end
  

  def test_will_do_boolean_error_checking_when_told
    sh = SubHash.new.only_symbol(:sym, "name", "val")
    sh.fill

    conversions = { :sym => [Conversion.for(:boolean)] }
    assert_raises_with_matching_message(StandardError,
            /^Error in the test hash: name's value must be a boolean, and 'val' doesn't look right/) {
      sh.apply(conversions)
    }
  end
  

  def test_will_do_alternative_error_checking_when_told
    sh = SubHash.new.only_symbol(:sym, "name", "val")
    sh.fill

    conversions = { :sym => [Conversion.for(["foo", "bar"])] }
    assert_raises_with_matching_message(StandardError,
            /^Error in the test hash: name's value must be one of 'foo' or 'bar', and 'val' doesn't look right/) {
      sh.apply(conversions)
    }
  end
  

  def test_will_do_exact_length_checking_when_told
    sh = SubHash.new.only_symbol(:sym, "name", ["one", "two"])
    sh.fill

    conversions = { :sym => [Conversion.for([:string]),  # actually not needed.
                             Conversion.for(:length => 5)] }
    assert_raises_with_matching_message(StandardError,
            /^Error in the test hash: name's value must be of length 5, and \["one", "two"\] doesn't look right/) {
      sh.apply(conversions)
    }
  end
  

  def test_will_do_range_length_checking_when_told
    sh = SubHash.new.only_symbol(:sym, "name", ["one", "two"])
    sh.fill

    conversions = { :sym => [Conversion.for([:string]),  # actually not needed.
                             Conversion.for(:length => 3..5)] }
    assert_raises_with_matching_message(StandardError,
            /^Error in the test hash: name's value must be a list whose length is in this range: 3..5, and \["one", "two"\] doesn't look right/) {
      sh.apply(conversions)
    }
  end
  


  def test_it_is_ok_for_key_not_to_appear
    sh = SubHash.new.only_symbol(:sym, "name", "val")
    sh.fill

    conversions = { :another => [Conversion.for(:integer)] }
    sh.apply(conversions)
    assert_equal('val', sh[:sym])
    assert_equal(nil, sh[:another])
  end

end

class DefaultSourceTest < Test::Unit::TestCase
  include UserChoices
  
  def setup
    @choices = DefaultSource.new.use_hash(:a => 'a')
    @choices.fill
  end

  def test_default_values_are_created_with_key_not_string
    assert_equal(1, @choices.size)
    assert_equal('a', @choices[:a])
    assert_equal(':a', @choices.external_names[:a])
  end

  def test_nil_is_default_default
    assert_nil(@choices[:foo])
  end


  def test_error_message_will_look_good
    assert_raises_with_matching_message(StandardError,
            /^Error in the default values: :a's value/) {
      @choices.apply( :a => [Conversion.for(:integer)])
    }
  end

  def test_value_conversions_are_from_strings
    c = DefaultSource.new.use_hash(:a => '5')
    c.fill
    
    c.apply(:a => [Conversion.for(:integer)])
    assert_equal(5, c[:a])
  end

end

class EnvironmentSourceTest < Test::Unit::TestCase
  include UserChoices

  def test_the_environment_args_of_interest_can_be_described_by_prefix
    with_environment_vars('amazon_option' => "1") do
      choices = EnvironmentSource.new.with_prefix('amazon_')
      choices.fill
      assert_true(choices.has_key?(:option))
      assert_equal('1', choices[:option])
    end
  end

  def test_the_environment_args_can_use_empty_string_as_the_prefix
    # Though it's a silly thing to do.
    with_environment_vars('amazon_option' => "1") do
      choices = EnvironmentSource.new.with_prefix('')
      choices.fill
      assert_true(choices.has_key?(:amazon_option))
      assert_equal('1', choices[:amazon_option])
    end
  end

  def test_the_environment_args_of_interest_can_be_listed_explicitly
    with_environment_vars('amazon_option' => "1",
                          'root' => 'ok',
                          '~' => 'ok, too') do
      choices = EnvironmentSource.new.mapping(:option => 'amazon_option',
                                               :root => 'root',
                                               :home => '~')
      choices.fill
      assert_equal(3, choices.size)
      assert_equal('1', choices[:option])
      assert_equal('ok', choices[:root])
      assert_equal('ok, too', choices[:home])
    end
  end
  
  def test_can_also_combine_both_forms
    with_environment_vars('amazon_o' => "1",
                          'other_option' => 'still found') do
      choices = EnvironmentSource.new.with_prefix('amazon_').mapping(:other => 'other_option')
      choices.fill

      assert_equal(2, choices.size)
      assert_equal('1', choices[:o])
      assert_equal('still found', choices[:other])
    end
  end
  
  def test_the_order_of_combination_does_not_matter
    with_environment_vars('amazon_o' => "1",
                          'other_option' => 'still found') do
      choices = EnvironmentSource.new.mapping(:other => 'other_option').with_prefix('amazon_')
      choices.fill

      assert_equal(2, choices.size)
      assert_equal('1', choices[:o])
      assert_equal('still found', choices[:other])
    end
  end
  
  def test_unmentioned_environment_vars_are_ignored
    with_environment_vars('unfound' => "1") do
      choices = EnvironmentSource.new.with_prefix("my_")
      choices.fill
      assert_true(choices.empty?)
    end
  end

  def test_nil_is_default
    with_environment_vars('found' => "1") do
      choices = EnvironmentSource.new.mapping(:option => 'f')
      choices.fill
      assert_nil(choices[:foo])
      assert_nil(choices[:option]) # for fun
    end
  end

  def test_value_checking_is_set_up_properly
    with_environment_vars('amazon_option' => "1") do
      assert_raises_with_matching_message(StandardError,
            /^Error in the environment: amazon_option's value/) {
        choices = EnvironmentSource.new.with_prefix('amazon_')
        choices.fill
        choices.apply(:option => [Conversion.for(:boolean)])
      }
    end
  end

  def test_value_conversion_is_set_up_properly
    with_environment_vars('a' => "1", 'names' => 'foo,bar') do
      choices = EnvironmentSource.new.mapping(:a => 'a', :names => 'names')
      choices.fill
      choices.apply(:a => [Conversion.for(:integer)], 
                    :names => [Conversion.for([:string])])
      assert_equal(1, choices[:a])
      assert_equal(['foo', 'bar'], choices[:names])
    end
  end


end

# Common behavior for all config files. Using XML as an example.
class FileSourceTestCase < Test::Unit::TestCase
  include UserChoices
  
  def setup
    builder = Builder::XmlMarkup.new(:indent => 2)
    @some_xml = builder.config {
      builder.reverse("true")
      builder.maximum("53")
      builder.host('a.com')
      builder.host('b.com')
    }
  end
  

  def test_config_file_need_not_exist
    assert_false(File.exist?(".amazonrc"))
    choices = XmlConfigFileSource.new.from_file(".amazonrc")

    assert_true(choices.empty?)
  end


  def test_config_file_value_checking_is_set_up_properly
    with_local_config_file(".amazonrc", @some_xml) do
      assert_raises_with_matching_message(StandardError,
           %r{Error in configuration file ./.amazonrc: maximum's value.*'low'.*'high'}) {
        choices = XmlConfigFileSource.new.from_file(".amazonrc")
        choices.fill
        choices.apply(:maximum => [Conversion.for(['low', 'high'])])
      }
    end
  end


  def test_value_conversions_are_set_up_properly
    with_local_config_file('.amazonrc', @some_xml) do
      choices = XmlConfigFileSource.new.from_file('.amazonrc')
      choices.fill
      choices.apply(:maximum => [Conversion.for(:integer)])
      assert_equal(53, choices[:maximum])
    end
  end
  
  def test_complete_paths_to_config_file_are_allowed
    tempfile = Tempfile.new('path-test')
    tempfile.puts(@some_xml)
    tempfile.close
    choices = XmlConfigFileSource.new.from_complete_path(tempfile.path)
    choices.fill
    assert_equal('53', choices[:maximum])
  end



  def test_unmentioned_values_are_nil
    with_local_config_file('.amazonrc', @some_xml) do
      choices = XmlConfigFileSource.new.from_file('.amazonrc')
      choices.fill
      assert_nil(choices[:unmentioned])
    end
  end

  def test_dashed_choice_names_are_underscored
    with_local_config_file('.amazonrc', "<config><the-name>5</the-name></config>") do
      choices = XmlConfigFileSource.new.from_file('.amazonrc')
      choices.fill
      assert_equal('5', choices[:the_name])
    end
  end

  
end



class XmlConfigFileSourceTestCase < Test::Unit::TestCase
  include UserChoices

  def setup
    builder = Builder::XmlMarkup.new(:indent => 2)
    @some_xml = builder.config {
      builder.reverse("true")
      builder.maximum("53")
      builder.host('a.com')
      builder.host('b.com')
    }
  end
    
  def test_xml_config_file_normal_use
    with_local_config_file('.amazonrc', @some_xml) {
      choices = XmlConfigFileSource.new.from_file(".amazonrc")
      choices.fill
      choices.apply(:reverse => [Conversion.for(:boolean)],
                    :maximum => [Conversion.for(:integer)])

      assert_equal(3, choices.size)
      assert_equal(true, choices[:reverse])
      assert_equal(53, choices[:maximum])
      assert_equal(['a.com', 'b.com'], choices[:host])
    }
  end

  def test_config_file_with_bad_xml
    with_local_config_file('.amazonrc',"<malformed></xml>") {
      assert_raise_with_matching_message(REXML::ParseException,
          %r{Badly formatted configuration file ./.amazonrc: .*Missing end tag}) do
              XmlConfigFileSource.new.from_file(".amazonrc")
      end
    }
  end


end


class YamlConfigFileSourceTestCase < Test::Unit::TestCase
  include UserChoices

  def setup
    @some_yaml = "
    | ---
    | reverse: true
    | maximum: 53
    | host:
    |   - a.com
    |   - b.com
    | list-arg: 1,2, 3
    ".without_pretty_indentation('|')
  end
  
  def test_string_assurance
    choices = YamlConfigFileSource.new
    a = [1]
    choices.ensure_element_is_string(a, 0)
    assert_equal(["1"], a)
    
    h = {'foo' => false }
    choices.ensure_element_is_string(h, 'foo')
    assert_equal({'foo' => 'false'}, h)
    
    a = [1, 2.0, true, 'already']
    choices.ensure_array_values_are_strings(a)
    assert_equal(['1', '2.0', 'true', 'already'], a)

    h = {'1' => '2', 'false' => true, 99 => 100 }
    choices.ensure_hash_values_are_strings(h)
    assert_equal({'1' => '2', 'false' => 'true', 99 => '100' }, h)

    h = {'1' => '2', 'false' => [1, true], 99 => {100 => true}}
    choices.ensure_hash_values_are_strings(h)
    assert_equal({'1' => '2', 'false' => ['1', 'true'], 99 => {100 => 'true'} }, h)
  end
  
  def test_yaml_config_file_normal_use
    with_local_config_file('.amazonrc', @some_yaml) {
      choices = YamlConfigFileSource.new.from_file(".amazonrc")
      choices.fill

      assert_equal(4, choices.size)
      assert_equal("true", choices[:reverse])
      assert_equal("53", choices[:maximum])
      assert_equal(['a.com', 'b.com'], choices[:host])
      assert_equal("1,2, 3", choices[:list_arg])
    }
  end

  def test_config_file_with_bad_yaml
    with_local_config_file('.amazonrc',"foo:\n\tfred") {
      assert_raise_with_matching_message(ArgumentError,
          %r{Badly formatted configuration file ./.amazonrc: .*syntax error}) do
              pp YamlConfigFileSource.new.from_file(".amazonrc"), 'should never have been reached'
      end
    }
  end




end
