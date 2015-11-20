require 'pry'
require_relative 'scanner'

class ForYears < Scanner

  def do_it!

    output_hash = {}

    units = %w(seconds? minutes? hours? days? weeks? months? years? decades?)
    maybe_words = ['for about', 'for over', 'more than', 'for the past',
      'for going on', 'for almost', 'now', 'for', 'about', 'almost', 'over',
      'the', 'going', 'this', 'nearly']
    maybe_string = maybe_words.join('|')
    regexp = /I(?:'ve| have) (?:had|have|been) ([^.!?,\d]+?)\s?(?:#{maybe_string})?\s?(\d+) (#{units.join('|')})/

    process_content do |content|
      content.scan regexp do |thing, number, unit|
        output_hash[thing.downcase] ||= {}
        output_hash[thing.downcase][unit] ||= {}
        output_hash[thing.downcase][unit][number] ||= 0
        output_hash[thing.downcase][unit][number] += 1
      end
    end

    output = output_hash.map do |thing, unit|
      unit = unit.map do |unit, numbers|
        numbers = numbers.sort_by{|k,v| k.to_i}.to_h
        [unit, numbers]
      end
      unit = unit.to_h
      [thing, unit]
    end
    output = output.sort_by{|k,v|
      v.to_a.map{|a|a[1]}.map{|h|h.length}.inject(0){|m,c|m += c}
    }.reverse.to_h
    write_output output.to_yaml
  end

end

ForYears.new.do_it!
