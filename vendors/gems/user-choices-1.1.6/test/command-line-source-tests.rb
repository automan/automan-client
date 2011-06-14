require 'test/unit'
require 's4t-utils'
require 'builder'
require 'user-choices'
include S4tUtils
set_test_paths(__FILE__)

              ### Handling of options with arguments ###

class CommandLineTestCase < Test::Unit::TestCase
  include UserChoices
  
  def setup
    @cmd_line = CommandLineSource.new
  end

  def default_test
  end
end

class OPTIONS_CommandLineTests < CommandLineTestCase
  def test_options_can_be_given_in_the_command_line
    with_command_args('--given-option value') {
      @cmd_line.uses_option(:given_option, "--given-option VALUE")
      @cmd_line.fill

      assert_true(@cmd_line.has_key?(:given_option))
      assert_equal("value", @cmd_line[:given_option])

      assert_false(@cmd_line.has_key?(:unspecified_option))
      assert_equal(nil, @cmd_line[:unspecified_option])
    }
  end

  def test_the_specification_can_describe_options_that_are_not_given
    # They're really /optional/.
    with_command_args('') { 
      @cmd_line.uses_option(:unused_option, "--unused-option VALUE")
      @cmd_line.fill

      assert_false(@cmd_line.has_key?(:unused_option))
      assert_equal(nil, @cmd_line[:unused_option])
    }
  end

  def test_options_can_have_one_letter_abbreviations
    with_command_args('-s s-value --option=option-value') {
      @cmd_line.uses_option(:option, "-o", "--option=VALUE")
      @cmd_line.uses_option(:something, "-s", "--something=VALUE")
      @cmd_line.fill
      
      assert_equal("s-value", @cmd_line[:something])
      assert_equal("option-value", @cmd_line[:option])
    }
  end



  def test_command_line_list_of_possible_values_checking
    with_command_args("-n true") do
      @cmd_line.uses_option(:north_west, "-n", "--north-west=VALUE")
      @cmd_line.fill
      output = capturing_stderr do
        assert_wants_to_exit do
          @cmd_line.apply({:north_west => [Conversion.for(['low', 'high'])]})
        end
      end
      assert_match(%r{Error in the command line: --north-west's value}, output)
    end
  end

  def test_command_line_integer_value_checking
    with_command_args("--day-count-max=2d3") do
      @cmd_line.uses_option(:day_count_max, "--day-count-max=VALUE")
      @cmd_line.fill
      output = capturing_stderr do
        assert_wants_to_exit do
          @cmd_line.apply({:day_count_max => [Conversion.for(:integer)]})
        end
      end
      assert_match(/^Error in the command line: --day-count-max's value/, output)
    end
  end


  def test_integer_conversion
    with_command_args("--day-count-max 23") do
      @cmd_line.uses_option(:day_count_max, "--day-count-max=VALUE")
      @cmd_line.fill
      @cmd_line.apply({:day_count_max => [Conversion.for(:integer)]})
      assert_equal(23, @cmd_line[:day_count_max])
    end
  end

  def test_array_value_conversion_with_proper_multivalue_declaration
    with_command_args("--hosts localhost,foo.com") do
      @cmd_line.uses_option(:hosts, "--hosts HOST,HOST")
      @cmd_line.fill
      @cmd_line.apply({:hosts => [Conversion.for([:string])]})
      assert_equal(['localhost', 'foo.com'],
                   @cmd_line[:hosts])
    end
  end

  def test_array_value_conversion_without_proper_multivalue_declaration_still_works
    with_command_args("--hosts localhost,foo.com") do
      @cmd_line.uses_option(:hosts, "--hosts HOSTS...")
      @cmd_line.fill
      @cmd_line.apply({:hosts => [Conversion.for([:string])]})
      assert_equal(['localhost', 'foo.com'],
                   @cmd_line[:hosts])
    end
  end

end



                       ### Boolean switches ###

# Note that switches are string-valued for consistency with
# other sources (like environment variables).
class SWITCHES_CommandLineTest < CommandLineTestCase

  def test_boolean_switches_are_accepted
    with_command_args("--c") do
      @cmd_line.uses_switch(:csv, "-c", "--csv")
      @cmd_line.fill
      assert_equal("true", @cmd_line[:csv])
      
      # ... but they can be converted into booleans
      @cmd_line.apply({:csv => [Conversion.for(:boolean)]})
      assert_equal(true, @cmd_line[:csv])
    end
  end

  def test_unmentioned_switches_have_no_value
    with_command_args("") do
      @cmd_line.uses_switch(:csv, "-c", "--csv")
      @cmd_line.fill
      assert_false(@cmd_line.has_key?(:csv))
    end
  end

  def test_switches_can_be_explicitly_false
    with_command_args("--no-csv") do
      @cmd_line.uses_switch(:csv, "-c", "--csv")
      @cmd_line.fill
      assert_equal("false", @cmd_line[:csv])
    end
  end
end


                        ### Argument Lists ###

# Arguments lists are treated as another option.
class ARGLISTS_CommandLineTest < CommandLineTestCase

  def test_by_default_arglists_are_not_allowed
    # Note that the error check is done at fill time, not apply time.
    with_command_args("one") {
      output = capturing_stderr do
        assert_wants_to_exit do
          @cmd_line.fill
        end
      end
      
      assert_match(/^Error in the command line: No arguments are allowed./, output)
    }
  end
  
  def test_empty_arglists_are_OK_if_arglist_not_described
    with_command_args("") {
      output = capturing_stderr do
        @cmd_line.fill
      end
      assert_equal("", output)  # No error message
    }
  end
  
  def test_arglist_after_options_can_turned_into_an_option
    with_command_args("--unused unused arg1 arg2") {
      @cmd_line.uses_option(:unused, "--unused VALUE")  # just for grins
      @cmd_line.uses_arglist(:args)
      @cmd_line.fill
      assert_true(@cmd_line.has_key?(:args))
      assert_equal(["arg1", "arg2"], @cmd_line[:args])
    }
  end

  def test_arglist_can_check_allowable_number_of_arguments
    with_command_args("--unused unused arg1 arg2") {
      @cmd_line.uses_option(:unused, "--unused VALUE")  # just for grins
      @cmd_line.uses_arglist(:args)
      @cmd_line.fill
      @cmd_line.apply({:args => [Conversion.for({:length => 2})]})
      assert_true(@cmd_line.has_key?(:args))
      assert_equal(["arg1", "arg2"], @cmd_line[:args])
    }
  end

  def test_error_if_exact_arglist_number_is_wrong
    with_command_args("arg1 arg2") {
      @cmd_line.uses_arglist(:args)
      @cmd_line.fill
      output = capturing_stderr do
        assert_wants_to_exit do
          @cmd_line.apply({:args => [Conversion.for({:length => 3})]})
        end
      end
      assert_match(/^Error in the command line:.*2 arguments given, 3 expected./, output)
    }
  end

  def test_arglist_arity_can_be_a_range
    with_command_args("arg1 arg2") {
      @cmd_line.uses_arglist(:args)
      @cmd_line.fill
      @cmd_line.apply({:args => [Conversion.for({:length => 1..2})]})
      assert_true(@cmd_line.has_key?(:args))
      assert_equal(["arg1", "arg2"], @cmd_line[:args])
    }
  end


  def test_error_if_arglist_does_not_match_range
    with_command_args("arg1 arg2") {
      @cmd_line.uses_arglist(:args)
      @cmd_line.fill
      output = capturing_stderr do
        assert_wants_to_exit do    
          @cmd_line.apply({:args => [Conversion.for({:length => 3..6})]})
        end
      end
      assert_match(/^Error in the command line:.*2 arguments given, 3 to 6 expected./, output)
    }
  end
  
  def test_arglist_external_name_is_friendly
    @cmd_line.uses_arglist(:fred)
    assert_equal("the argument list", @cmd_line.external_names[:fred])
  end

  def test_deep_copy_of_conversion_map
    map = { :choice => [Conversion.for([:string]), Conversion.for(:length => 3)]}
    copy = @cmd_line.deep_copy(map)
    assert_not_equal(map[:choice].collect { |c| c.object_id }, 
                     copy[:choice].collect { |c| c.object_id })
    assert_true(copy[:choice][0].class.described_by?([:string]))
    assert_true(copy[:choice][1].class.described_by?(:length => 3))
    
    map.delete(:choice)
    assert_false(map.has_key?(:choice))
    assert_true(copy.has_key?(:choice))
  end
end

class ARG_CommandLineTest < CommandLineTestCase
  include UserChoices


  def test_a_singleton_arg_will_not_be_in_a_list
    with_command_args("arg-only") {
      @cmd_line.uses_option(:unused, "--unused VALUE")  # just for grins
      @cmd_line.uses_arg(:arg)
      @cmd_line.fill
      assert_true(@cmd_line.has_key?(:arg))
      assert_equal("arg-only", @cmd_line[:arg])
    }
  end

  def test_singleton_args_are_incompatible_with_length_checks
    # Because the missing argument might be filled in by other chained sources.
    with_command_args("1") {
      @cmd_line.uses_arg(:arg)
      @cmd_line.fill
      assert_raises_with_matching_message(StandardError, "Don't specify the length of an argument list when it's not treated as an array.") {
        @cmd_line.apply({:arg => [Conversion.for(:length => 1)]})
      }
    }
  end
  
  
  
  def test_extra_singleton_args_generate_errors
    # Note that it's caught in the 'fill' step.
    with_command_args("1 2") {
      @cmd_line.uses_arg(:arg)
      output = capturing_stderr do
        assert_wants_to_exit do    
          @cmd_line.fill
        end
      end
      assert_match(/^Error in the command line: .*2 arguments given, 1 expected/, output)
    }
  end

  def test_singleton_arguments_can_be_optional
    with_command_args("") {
      @cmd_line.uses_optional_arg(:arg)
      @cmd_line.fill
      assert_false(@cmd_line.has_key?(:arg))
      assert_equal(nil, @cmd_line[:arg])
    }
  end

  def test_optional_arguments_can_be_given
    with_command_args("only") {
      @cmd_line.uses_optional_arg(:arg)
      @cmd_line.fill
      assert_equal('only', @cmd_line[:arg])
    }
  end


  def test_that_optional_singleton_arguments_still_precludes_two
    # Note that the error check is done at fill time, not apply time.
    with_command_args("one two") {
      @cmd_line.uses_optional_arg(:arg)
      output = capturing_stderr do
        assert_wants_to_exit do    
          @cmd_line.fill
        end
      end
      assert_match(/^Error in the command line:.*2 arguments given, 0 or 1 expected./, output)
    }
  end
  
  def test_arg_external_name_is_friendly
    @cmd_line.uses_arg(:fred)
    assert_equal("the argument list", @cmd_line.external_names[:fred])
  end
  
  
  def test_optional_arg_external_name_is_friendly
    @cmd_line.uses_optional_arg(:fred)
    assert_equal("the argument list", @cmd_line.external_names[:fred])
  end
  
end

                    ### Option-Handling Style ###

class OPTION_STYLE_CommandLineTest < CommandLineTestCase
  include UserChoices
  
  def define(klass)
    @cmd_line = klass.new
    @cmd_line.uses_switch(:switch, "--switch")
    @cmd_line.uses_arglist(:args)
    @cmd_line.fill
  end

  def test_default_style_is_permutation
    with_command_args('3 --switch 5') {
      define(CommandLineSource)
      assert_equal('true', @cmd_line[:switch])
      assert_equal(['3', '5'], @cmd_line[:args])
    }
  end

  def test_subclass_allows_all_options_before_arguments
    with_command_args('3 --switch 5') { 
      define(PosixCommandLineSource)
      assert_equal(nil, @cmd_line[:switch])
      assert_equal(['3', '--switch', '5'], @cmd_line[:args])
    }
  end

  def test_choosing_posix_parsing_does_not_override_environment_variable
    with_environment_vars('POSIXLY_CORRECT' => 'hello') do
      with_command_args('3 --switch 5') { 
        define(PosixCommandLineSource)
        assert_equal('hello', ENV['POSIXLY_CORRECT'])
      }
    end
  end
    
end

                        ### Error Handling ###

# Additional commandline-specific error checking.
class ERROR_CommandLineTest < CommandLineTestCase
  include UserChoices

  def test_invalid_option_produces_error_message_and_exit
    with_command_args('--doofus 3') {
      output = capturing_stderr do
        assert_wants_to_exit do
          @cmd_line.uses_option(:doofus, "--option VALUE")
          @cmd_line.fill
        end
      end

      assert_match(/invalid option.*doofus/, output)
    }
  end

  def test_error_is_identified_as_coming_from_the_command_line
    with_command_args('--doofus') {
      output = capturing_stderr do
        assert_wants_to_exit do
          @cmd_line.uses_option(:doofus, "--doofus VALUE")
          @cmd_line.fill
        end
      end
      
      assert_match(/^Error in the command line:.*missing argument.*doofus/, output)
    }
  end

  def test_errors_cause_usage_style_output
    with_command_args('wanted --wanted') {
      output = capturing_stderr do
        assert_wants_to_exit do
            default_isbn = "343"
            @cmd_line.help_banner("Usage: ruby prog [options] [isbn]",
                          "This and further strings are optional.")
            @cmd_line.uses_option(:option, "-o", "--option=VALUE",
                          "Message about option",
                          "More about option")
            @cmd_line.fill
        end
      end

      lines = output.split($/)
      # puts output
      assert_match(/^Error in the command line: /, lines[0])
      assert_equal("Usage: ruby prog [options] [isbn]", lines[1])
      assert_match(/This and further/, lines[2])
      assert_match(/\s*/, lines[3])
      assert_match(/Options:/, lines[4])
      assert_match(/-o.*--option=VALUE.*Message about option/, lines[5])
      assert_match(/More about option/, lines[6])
      assert_match(/--help.*Show this message/, lines.last)
    }
  end
  
end


