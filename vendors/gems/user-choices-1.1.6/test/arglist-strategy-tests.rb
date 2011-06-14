#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-08-10.
#  Copyright (c) 2007. All rights reserved.

require 'test/unit'
require 's4t-utils'
require 'builder'
require 'user-choices/arglist-strategies'
include S4tUtils
set_test_paths(__FILE__)

# Since ArglistStrategies were extracted from CommandLineSource, most
# of the testing is implicit.

class AbstractArglistStrategyTests < Test::Unit::TestCase
  include UserChoices
  
  def test_range_violation_descriptions
    @arglist_handler = AbstractArglistStrategy.new('unimportant')
    # Good about plurals.
    assert_match(/2 arguments given, 3 expected/,
                 @arglist_handler.arglist_arity_error(2, 3))

    assert_match(/1 argument given, 3 expected/,
                 @arglist_handler.arglist_arity_error(1, 3))

    assert_match(/0 arguments given, 1 expected/,
                 @arglist_handler.arglist_arity_error(0, 1))

    # Handle both types of ranges.
    assert_match(/2 arguments given, 3 to 5 expected/, 
                 @arglist_handler.arglist_arity_error(2, 3..5))
    assert_match(/1 argument given, 3 to 5 expected/, 
                 @arglist_handler.arglist_arity_error(1, 3...6))

    # Use 'or' if there are only two alternatives.
    assert_match(/2 arguments given, 3 or 4 expected/, 
                 @arglist_handler.arglist_arity_error(2, 3..4))

  end
end