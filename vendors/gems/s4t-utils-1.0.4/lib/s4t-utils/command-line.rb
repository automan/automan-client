module S4tUtils

  module_function

  # Ask the question contained in the _question_lines_, prompt, and
  # wait for an answer. If the stripped value read from STDIN is 
  # empty, use the _default_answer_.
  def ask(default_answer, *question_lines)
    puts question_lines
    print "[#{default_answer}] => "
    answer = STDIN.readline.strip
    answer = default_answer.to_s if answer == ''
    answer
  end

end


