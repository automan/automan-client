#--
# Note: see also <http://englishext.rubyforge.org/>
#++

module S4tUtils

  module_function

  # Use _connector_ to join _array_ into a human-friendly list.
  #
  #
  #    friendly_list("or", [1])   => "'1'"
  #    friendly_list("or"), [1, 2]  => "'1' or '2'"
  #    friendly_list("or"), [1, 2, 3] => "'1', '2', or '3'"
  def friendly_list(connector, array)
    quoted = array.collect { | elt | "'" + elt.to_s + "'" }
    case array.length
    when 0
      ""
    when 1
      quoted[0]
    when 2
      quoted[0] + " #{connector} " + quoted[1]
    else
      quoted[0...-1].join(", ") + ", #{connector} #{quoted.last}"
    end
  end

  # Produces a version of a string that can be typed after a :
  # (Can also be safely given at a command-line prompt.)
  def symbol_safe_name(name)
    name.to_s.gsub(/\W/, '')
  end
end

