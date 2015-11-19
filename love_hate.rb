require_relative 'scanner'
require 'yaml'

class LoveHate < Scanner

  def do_it!
    output_hash = {}
    process_content do |content|
      content.scan /I (love|hate) my\s+\d*\s*(\w+)\b/ do |feeling, thing|
        output_hash[thing.downcase] ||= {'love' => 0, 'hate' => 0}
        output_hash[thing.downcase][feeling] += 1
      end
    end
    output = output_hash.sort_by{|k,v|v['hate'] + v['love']}.reverse.to_h
    write_output output.to_yaml
  end

end

LoveHate.new.do_it!
