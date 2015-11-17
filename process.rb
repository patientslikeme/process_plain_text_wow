require 'csv'
require 'nokogiri'

def to_emoticon_text(string)
  "[[[#{string.gsub(/\b\s*emoticon\s*\b/, '')}]]]"
end

def replace_img_emoticons(doc)
  doc.css('img.wysihtml5-emoticon-icon').each do |img|
    span = doc.create_element "span"
    span.inner_html = to_emoticon_text img['alt']
    img.replace span
  end
end

def replace_span_emoticons(doc)
  doc.css('span.emoticon').each do |span|
    span.inner_html = to_emoticon_text span.inner_html
  end
end

def replace_emoticons(doc)
  replace_img_emoticons(doc)
  replace_span_emoticons(doc)
  doc
end

def process_content(content)
  replace_emoticons(Nokogiri::HTML(content)).text
end

def die(message)
  puts "Usage: bundle exec ruby process.rb input_file output_file"
  puts
  abort("Error: #{message}")
end

input_filename = ARGV[0]
output_filename = ARGV[1]
die('You must specify an input and output file') if input_filename.nil? || output_filename.nil?
die("The input file \"#{input_filename}\" does not exist") unless File.exists?(input_filename)

headers = File.open(input_filename, &:readline).split(',').map(&:chomp)

File.open(output_filename, 'w') do |file|
  CSV.new(file, write_headers: true, headers: headers).tap do |csv|
    CSV.read(input_filename, headers: true).map do |row|
      csv << row.to_a.map do |field|
        field[0] == 'content' ? process_content(field[1])  : field[1]
      end
    end
  end
end
