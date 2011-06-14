#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-27.
#  Copyright (c) 2007. All rights reserved.

# After some time trying to write libraries that used facets or extensions
# and didn't conflict with other libraries that used (for example) active_support, 
# I give up. I'm going to copy the methods I need, rename them to something so 
# bad there'll never be a conflict, and see if that's more painful.
class String  
  # What everyone calls starts_with?
  def has_exact_prefix?(prefix)
   index(prefix) == 0
  end
  
  # Copied from the extensions library (http://extensions.rubyforge.org)
  #
  # Trims a string:
  # - removes one initial blank line
  # - removes trailing spaces on each line
  # - if +margin+ is given, removes initial spaces up to and including
  #   the margin on each line, plus one space
  #
  # This is designed specifically for working with inline documents.
  # Here-documents are great, except they tend to go against the indentation
  # of your code.  This method allows a convenient way of using %{}-style
  # documents.  For instance:
  #
  #   USAGE = %{
  #     | usage: prog [-o dir] -h file...
  #     |   where
  #     |     -o dir         outputs to DIR
  #     |     -h             prints this message
  #   }.without_pretty_indentation("|")
  #
  #   # USAGE == "usage: prog [-o dir] -h file...\n  where"...
  #   # (note single space to right of margin is deleted)
  #
  # Note carefully that if no margin string is given, then there is no
  # clipping at the beginning of each line and your string will remain
  # indented.  
  def without_pretty_indentation(margin=nil)
    s = self.dup
    # Remove initial blank line.
    s.sub!(/\A[ \t]*\n/, "")
    # Get rid of the margin, if it's specified.
    unless margin.nil?
      margin_re = Regexp.escape(margin || "")
      margin_re = /^[ \t]*#{margin_re} ?/
      s.gsub!(margin_re, "")
    end
    # Remove trailing whitespace on each line
    s.gsub!(/[ \t]+$/, "")
    s
  end
  
  #
  # Indents the string +n+ spaces.
  # Taken from extensions (extensions.rubyforge.org), except that this
  # version doesn't take a negative argument.
  #
  def indent_by(n)
    n = n.to_int
    gsub(/^/, " "*n)
  end
  
end
