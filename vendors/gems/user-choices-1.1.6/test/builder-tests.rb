require 'test/unit'
require 's4t-utils'
require 'user-choices'
include S4tUtils
set_test_paths(__FILE__)


class TestDefaultsAndTypes < Test::Unit::TestCase
  include UserChoices

  def test_builder_can_add_defaults
    b = ChoicesBuilder.new
    b.add_choice(:trip_steps, :default => '5')
    choices = b.build
    assert_equal('5', choices[:trip_steps])
  end

  def test_defaults_need_not_be_strings
    b = ChoicesBuilder.new
    b.add_choice(:trip_steps, :default => 5)
    choices = b.build
    assert_equal(5, choices[:trip_steps])
  end

  def test_builder_can_declare_types_and_do_error_checking
    b = ChoicesBuilder.new
    b.add_choice(:trip_steps, :default => 'a', :type => :integer)
    assert_raises_with_matching_message(StandardError,
                                        /:trip_steps's value must be an integer, and 'a'/) {
      b.build
    }
  end

  def test_builder_can_declare_types_and_do_conversions
    b = ChoicesBuilder.new
    b.add_choice(:csv, :default => 'true', :type => :boolean)
    choices = b.build
    assert_equal(true, choices[:csv])
  end

  def test_some_types_cause_no_conversion
    # Checking is done
    b = ChoicesBuilder.new
    b.add_choice(:trip_steps, :default => 'a', :type => ['b', 'c'])
    assert_raises_with_matching_message(StandardError,
                                        /'a' doesn't look right/) {
      b.build
    }

    # ... but, if checking passes, no changes are made
    b = ChoicesBuilder.new
    b.add_choice(:trip_steps, :default => 'b', :type => ['b', 'c'])
    assert_equal('b', b.build[:trip_steps])
  end

  def test_arrays_can_be_built_from_comma_separated_list
    b = ChoicesBuilder.new
    b.add_choice(:targets, :default => 'a,b,cd',
                 :type => [:string])
    assert_equal(['a', 'b', 'cd'],
                 b.build[:targets])
  end

  def test_arrays_can_be_accepted_as_is
    b = ChoicesBuilder.new
    b.add_choice(:targets, :default => ['a', 'b', 'c'],
                 :type => [:string])
    assert_equal(['a', 'b', 'c'], b.build[:targets])
  end

  def test_arrays_are_constructed_from_single_elements
    b = ChoicesBuilder.new
    b.add_choice(:targets, :default => 'a',
                 :type => [:string])
    assert_equal(['a'], b.build[:targets])
  end
  
  def test_array_lengths_can_be_specified_exactly
    b = ChoicesBuilder.new
    b.add_choice(:targets, :length => 2, :default => ['wrong'])
    assert_raises_with_matching_message(StandardError, /must be of length 2/) {
      b.build
    }
  end

  def test_array_lengths_can_be_specified_by_range
    b = ChoicesBuilder.new
    b.add_choice(:targets, :length => 2..3, :default => ['wrong'])
    assert_raises_with_matching_message(StandardError, /this range: 2..3/) {
      b.build
    }
  end
  
  def test_array_lengths_apply_to_command_line_args # didn't used to, not in the same way.
    with_command_args("a b c d") {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, 'foo')
      b.add_choice(:targets, :length => 2..3) { |command_line |
        command_line.uses_arglist
      }
      
      output = capturing_stderr do
        assert_wants_to_exit do    
          b.build
        end
      end
      assert_match(/^Error in the command line: 4 arguments given, 2 or 3 expected/, output)
    }
  end
  
  def test_missing_required_arg_is_caught_by_command_line
    with_command_args("") {
      b = ChoicesBuilder.new
      b.add_source(PosixCommandLineSource, :usage, 'foo')
      b.add_choice(:targets) { |command_line |
        command_line.uses_arg
      }
      
      output = capturing_stderr do
        assert_wants_to_exit do    
          b.build
        end
      end
      assert_match(/^Error in the command line: 0 arguments given, 1 expected/, output)
    }
  end
  
  def test_extra_required_arg_is_caught_by_command_line
    with_command_args("one extra") {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, 'foo')
      b.add_choice(:targets) { |command_line |
        command_line.uses_arg
      }
      
      output = capturing_stderr do
        assert_wants_to_exit do    
          b.build
        end
      end
      assert_match(/^Error in the command line: 2 arguments given, 1 expected/, output)
    }
  end
  
  def test_extra_optional_arg_is_caught_by_command_line
    with_command_args("one extra") {
      b = ChoicesBuilder.new
      b.add_source(PosixCommandLineSource, :usage, 'foo')
      b.add_choice(:targets) { |command_line |
        command_line.uses_optional_arg
      }
      
      output = capturing_stderr do
        assert_wants_to_exit do    
          b.build
        end
      end
      assert_match(/^Error in the command line: 2 arguments given, 0 or 1 expected/, output)
    }
  end
end

class TestChainingOfSources < Test::Unit::TestCase
  include UserChoices

  def test_sources_are_chained_correctly
    with_environment_vars("prefix_in_ecd" =>  "e") {
      with_local_config_file(".builder_rc",
                             "<config>
                                <in_ecd>c</in_ecd>
                                <in_cd>c</in_cd>
                              </config>") {
        b = ChoicesBuilder.new
        b.add_source(EnvironmentSource, :with_prefix, "prefix_")
        b.add_source(XmlConfigFileSource, :from_file, ".builder_rc")

        b.add_choice(:in_ecd, :default => "d")
        b.add_choice(:in_cd, :default => "d")
        b.add_choice(:in_d, :default => "d")

        choices = b.build

        assert_equal('e', choices[:in_ecd])
        assert_equal('c', choices[:in_cd])
        assert_equal('d', choices[:in_d])
      }
    }
  end
  
  
  def test_priority_over_default
    with_command_args("--option perfectly-fine --only-cmd=oc") {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, "blah, blah")
      b.add_choice(:option, :default => '0.3') { | command_line |
        command_line.uses_option('--option VALUE')
      }
      b.add_choice(:only_cmd) { |command_line| 
        command_line.uses_option('--only-cmd VALUE')
      }
      b.add_choice(:only_default, :default => 'od')
      choices = b.build
      assert_equal("perfectly-fine", choices[:option])
      assert_equal("oc", choices[:only_cmd])
      assert_equal("od", choices[:only_default])
    }
  end

  def test_checking_is_done_for_all_sources
    with_command_args("--command-option perfectly-fine") {
      assert_raises_with_matching_message(StandardError, 
                                          /^Error in the default values/) {
        b = ChoicesBuilder.new
        b.add_source(CommandLineSource, :usage, "blah")
        b.add_choice(:command_option) { | command_line |
          command_line.uses_option('--command-option VALUE')
        }
        b.add_choice(:broken, :default => '0.3', :type => :integer)
        b.build
      }
    }
  end

  def test_conversions_are_done_for_all_sources
    with_environment_vars("amazon_rc" => "1") {
      b = ChoicesBuilder.new
      b.add_source(EnvironmentSource, :with_prefix, 'amazon')
      b.add_choice(:_rc, :type => :integer, :default => '3')
      assert_equal(1, b.build[:_rc])
    }
  end

  def test_unmentioned_choices_are_nil
    with_environment_vars("amazon_rc" => "1") {
      b = ChoicesBuilder.new
      b.add_source(EnvironmentSource, :with_prefix, 'amazon_')
      b.add_choice(:rc, :default => 5, :type => :integer)
      choices = b.build
      assert_equal(nil, choices[:unmentioned])
      assert_equal(1, choices[:rc])   # for fun
    }
  end

  def test_given_optional_args_override_lower_precedence_sources
    with_command_args("override") {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, "blah")
      b.add_choice(:name, :default => 'default') { | command_line |
        command_line.uses_optional_arg
      }
      choices = b.build
      assert_equal('override', choices[:name])
    }
  end

  def test_non_empty_arglists_override_lower_precedence_sources
    with_command_args("1") {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, 'blah')
      b.add_choice(:name, :default => ['default', '1']) { |command_line| 
        command_line.uses_arglist
      }
      assert_equal(['1'], b.build[:name])
    }
  end
  
end


class TestInteractionOfArglistsWithOtherSources < Test::Unit::TestCase
  include UserChoices 
  
  def test_missing_optional_args_do_not_override_lower_precedence_sources
    with_command_args("") {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, 'blah')
      b.add_choice(:name, :default => 'default') { |command_line| 
        command_line.uses_optional_arg
      }
      assert_equal('default', b.build[:name])
    }
  end

  def test_missing_optional_args_are_ok_if_no_lower_precedence_sources
    with_command_args("") {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, 'blah')
      b.add_choice(:name) { |command_line| 
        command_line.uses_optional_arg
      }
      assert_false(b.build.has_key?(:name))
    }
  end

  def test_present_optional_args_do_override_lower_precedence_sources
    with_command_args("1") {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, 'blah')
      b.add_choice(:name, :default => 'default') { |command_line| 
        command_line.uses_optional_arg
      }
      assert_equal('1', b.build[:name])
    }
  end
  


  def test_empty_arglists_do_not_override_lower_precedence_sources
    # nothing / stuff
    xml = "<config><names>1</names><names>2</names></config>"
    with_local_config_file("test-config", xml) {
      with_command_args("") {
        b = ChoicesBuilder.new 
        b.add_source(CommandLineSource, :usage, 'blah')
        b.add_source(XmlConfigFileSource, :from_file, 'test-config')
        b.add_choice(:names) { |command_line| 
          command_line.uses_arglist
        }
        assert_equal(['1', '2'], b.build[:names])
      }
    }
  end
  
  def test_default_empty_arglist_is_empty_array
    # nothing / nothing
    with_command_args("") {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, 'blah')
      b.add_choice(:names) { |command_line| 
        command_line.uses_arglist
      }
      assert_equal([], b.build[:names])
    }
  end
  
  def test_default_empty_arglist_can_be_set_explicitly
    # nothing / nothing
    with_command_args("") {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, 'blah')
      b.add_choice(:names, :default => ['fred']) { |command_line| 
        command_line.uses_arglist
      }
      assert_equal(['fred'], b.build[:names])
    }
  end
  
  def test_present_arglist_does_override_lower_precedence_sources
    # stuff / stuff
    with_command_args("1") {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, 'blah')
      b.add_choice(:names, :default => ['default']) { |command_line| 
        command_line.uses_arglist
      }
      assert_equal(['1'], b.build[:names])
    }
  end
  
  def test_setup_for_overridable_empty_argument_list_is_compatible_with_length
    # This is an implementation-dependent test. Command-line arguments can 
    # be empty, yet overridden by less-important sources. This is done by 
    # initializing the default value to the empty list. But that must not 
    # trigger the length check.
    with_command_args("1 2") {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, 'blah')
      b.add_choice(:names, :length => 2) { |command_line| 
        command_line.uses_arglist
      }
      assert_equal(['1', '2'], b.build[:names])
    }
  end
  
  def test_an_empty_arglist_is_caught_by_the_length_check
    with_command_args("") {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, 'blah')
      b.add_choice(:names, :length => 2) { |command_line| 
        command_line.uses_arglist
      }
      output = capturing_stderr do
        assert_wants_to_exit do
          b.build
        end
      end
      assert_match(/command line: 0 arguments given, 2 expected/, output)
    }
  end


  def test_choices_from_earlier_defaults_prevent_failing_arglist_arity_check
    with_command_args("") {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, 'blah')
      b.add_choice(:names, :length => 1..2, :default => ['1']) { |command_line| 
        command_line.uses_arglist
      }
      assert_equal(['1'], b.build[:names])
    }

  end
end

class TestCommandLineConstruction < Test::Unit::TestCase
  include UserChoices

  def test_command_line_choices_requires_blocks_for_initialization
    with_command_args("--switch -c 5 arg") {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, "hi")

      b.add_choice(:unused) { | command_line |
        command_line.uses_switch("-u", "--unused")
      }

      b.add_choice(:switch, :type=>:boolean) { | command_line |
        command_line.uses_switch("--switch")
      }

      b.add_choice(:clear, :type => :integer) { | command_line |
        command_line.uses_option("-c", "--clear N",
                            "Clear the frobbistat N times.")
      }

      b.add_choice(:args) { | command_line |
        command_line.uses_arglist
      }
        
      choices = b.build

      assert_equal(true, choices[:switch])
      assert_false(choices.has_key?(:unused))
      assert_equal(5, choices[:clear])
      assert_equal(['arg'], choices[:args])
    }
  end

  def test_command_line_source_initializes_help_text
    with_command_args('--help') {
      output = capturing_stderr do
        assert_wants_to_exit do
          b = ChoicesBuilder.new
          b.add_source(CommandLineSource, :usage,
                       "Usage: prog [options]",
                       "This is supplemental.")

          b.add_choice(:test, :type => :boolean) { | command_line |
            command_line.uses_switch("--test",
                                     "Here's text for a switch")
          }
          b.add_choice(:renew) { | command_line |
            command_line.uses_option("-r", "--renew VALUE",
                                     "Here's text for an option")
          }
          b.build
        end
      end
      assert(l1 = output.index("Usage: prog [options]"))
      assert(l2 = output.index("This is supplemental"))
      assert(l3 = output.index(/--\[no-\]test.*Here's text for a switch/))
      assert(l4 = output.index(/-r.*--renew.*VALUE.*Here's text for an option/))
      assert(l5 = output.index("--help"))

      assert(l1 < l2)
      assert(l2 < l3)
      assert(l3 < l4)
      assert(l4 < l5)
    }
  end
  
  def test_builder_can_add_separators_to_help_text
    with_command_args('--help') {
      output = capturing_stderr do
        assert_wants_to_exit do
          b = ChoicesBuilder.new
          b.add_source(CommandLineSource, :usage,
                       "Usage: prog [options]",
                       "This is supplemental.")

          b.add_help_line("==============")
          b.add_choice(:test) { | command_line |
            command_line.uses_switch("--test",
                                     "Here's text for a switch")
          }
          b.build
        end
      end
      assert(l1 = output.index("This is supplemental"))
      assert(l2 = output.index(/==============/))
      assert(l3 = output.index(/--\[no-\]test.*Here's text for a switch/))

      assert(l1 < l2)
      assert(l2 < l3)
    }
  end
  
  def test_builder_can_group_help_text_in_sections
    with_command_args('--help') {
      output = capturing_stderr do
        assert_wants_to_exit do
          b = ChoicesBuilder.new
          b.add_source(CommandLineSource, :usage,
                       "Usage: prog [options]",
                       "This is supplemental.")

          b.section("section head") do 
            b.add_choice(:test) { | command_line |
              command_line.uses_switch("--test",
                                       "Here's text for a switch")
            }
          end
          b.add_choice(:renew) { | command_line |
            command_line.uses_option("-r", "--renew VALUE",
                                     "Here's text for an option")
          }
          b.build
        end
      end
      assert(l1 = output.index("This is supplemental"))
      assert(l2 = output.index(/section head/))
      assert(l3 = output.index(/--\[no-\]test.*Here's text for a switch/))
      assert(l4 = output.index(/---------/))
      assert(l5 = output.index(/Here's text for an option/))

      assert(l1 < l2)
      assert(l2 < l3)
      assert(l3 < l4)
      assert(l4 < l5)
    }
  end
  
end
  
class TestSpecialCases  < Test::Unit::TestCase
  include UserChoices
  
  def test_environment_choices_can_be_given_prefix_and_mapping
    with_environment_vars("prefix_e" =>  "e", "HOME" => '/Users/marick') {
      b = ChoicesBuilder.new
      b.add_source(EnvironmentSource, :with_prefix, "prefix_", :mapping, {:home => "HOME" })
      b.add_choice(:e)
      b.add_choice(:home)
      choices = b.build
      assert_equal("e", choices[:e])
      assert_equal("/Users/marick", choices[:home])
    }
    
  end
  
  
  def test_required_arg_with_type_conversion
    with_command_args("2") {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, "blah")
      b.add_choice(:e, :type => :integer) { |command_line | 
        command_line.uses_arg
      }
      choices = b.build
      assert_equal(2, choices[:e])
    }
  end

  def test_required_arg_conversion_prints_right_message
    with_command_args("b") {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, "blah")
      b.add_choice(:e, :type => :integer) { |command_line | 
        command_line.uses_arg
      }
      output = capturing_stderr do
        assert_wants_to_exit do    
          b.build
        end
      end
      assert_no_match(/^Error in the command line: Error in the command line: /, output)
    }
  end

  def test_optional_arg_with_type_conversion
    with_command_args('2') {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, "blah")
      b.add_choice(:e, :type => :integer) { |command_line | 
        command_line.uses_optional_arg
      }
      choices = b.build
      assert_equal(2, choices[:e])
    }
  end

  def test_missing_optional_arg_with_type_conversion_is_OK
    # The type check applies only if the value is given.
    with_command_args('') {
      b = ChoicesBuilder.new
      b.add_source(CommandLineSource, :usage, "blah")
      b.add_choice(:e, :type => :integer) { |command_line | 
        command_line.uses_optional_arg
      }
      assert_equal(nil, b.build[:e])
    }
  end

end


class TestUtilities  < Test::Unit::TestCase
  include UserChoices
  
  def setup
    @builder = ChoicesBuilder.new
  end
  
  def test_message_send_splitter
    assert_equal([[:usage, 'arg']], 
                 @builder.message_sends([:usage, 'arg']))
    assert_equal([[:usage, 'arg1', 2]], 
                 @builder.message_sends([:usage, 'arg1', 2]))
    assert_equal([[:msg, 'arg1', 2], [:next, 1]], 
                 @builder.message_sends([:msg, 'arg1', 2, :next, 1]))
    # a common case
    assert_equal([[:with_prefix, 'p_'], [:mapping, {:home => 'home'}]],
                 @builder.message_sends([:with_prefix, 'p_', :mapping, {:home => 'home'}]))
  end
  
  def test_symbol_indices
    assert_equal([0, 3], @builder.symbol_indices([:foo, 1, 2, :bar, "quux"]))
  end
end


