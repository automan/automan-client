#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-08-10.
#  Copyright (c) 2007. All rights reserved.


class Range # :nodoc:
  def in_words
    last_element = self.last
    last_element -= 1 if exclude_end?
    "#{self.first} to #{last_element}"
  end
end

class String # :nodoc:
  def to_inputable_sym
    gsub(/-/, '_').to_sym
  end
end

