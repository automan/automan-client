module Test
  module Unit

    # Some additional Test::Unit assertions.
    module Assertions
      # Same as +assert+. I just like it better.
      def assert_true(boolean, message = nil)
        assert(boolean, message)
      end

      # Assert that the _boolean_ is false.
      def assert_false(boolean, message = nil)
        _wrap_assertion do
          assert_block(build_message(message, "<?> should be false or nil.", boolean)) { !boolean }
        end
      end

      # Like +assert_raise+, but the raised exception must contain a
      # +message+ matching (as in +assert_match+) the _message_ argument.
      def assert_raise_with_matching_message(exception_class, message, &block)
        exception = assert_raise(exception_class, &block)
        assert_match(message, exception.message)
      end
      alias_method :assert_raises_with_matching_message,
                   :assert_raise_with_matching_message

      # Assert that the block tried to +exit+. 
      def assert_wants_to_exit
        assert_raise(SystemExit) do
          yield
        end
      end
    end
  end
end
