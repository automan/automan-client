require 'rubygems' rescue nil
# IRB configuration.
IRB.conf[:EVAL_HISTORY] = 100
IRB.conf[:SAVE_HISTORY] = 1000

IRB.conf[:HISTORY_FILE] = begin
  File::expand_path("~/.irb_history") 
rescue ArgumentError => e
  "c:/.irb_history"
end

IRB.conf[:AUTO_INDENT] = true
IRB.conf[:USE_READLINE] = true
IRB.conf[:PROMPT_MODE] = :DEFAULT
IRB.conf[:LOAD_MODULES] = [] if IRB.conf[:LOAD_MODULES].nil?
['irb/completion', 'rubygems', 'stringio'].each do |mod|
  IRB.conf[:LOAD_MODULES] << mod unless IRB.conf[:LOAD_MODULES].include?(mod)
end
require 'automan/ext'
require 'automan/initializer'
require 'automan/version'
