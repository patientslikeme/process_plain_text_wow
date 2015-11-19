require_relative 'scanner'
require 'yaml'

class IFeel < Scanner

  def do_it!
    feel_hash = Hash.new(0)
    process_content do |content|
      content.scan /I (feel|felt) (.*?)\s*[,.?!]/ do |feel_or_felt, thing|
        feel_hash[thing.downcase] += 1
      end
    end
    output = feel_hash.sort_by{|k,v|v}.reverse.to_h
    write_output output.to_yaml
  end

end

IFeel.new.do_it!
