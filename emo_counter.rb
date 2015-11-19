require_relative 'scanner'

class EmoCounter < Scanner

  def do_it!
    output_hash = Hash.new(0)
    process_content do |content|
      content.scan /\[\[\[(.*?)\]\]\]/ do |emo, _nothing|
        output_hash[emo] += 1
      end
    end
    write_output output_hash.sort_by{|k,v|v}.reverse.map{ |emo, count| "#{emo}: #{count}" }
  end

end

EmoCounter.new.do_it!
