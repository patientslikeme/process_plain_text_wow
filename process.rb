require 'csv'
require 'nokogiri'
require './emo'
require 'progress_bar'

def to_emoticon_text(string)
  "[[[#{string.gsub(/\b\s*emoticon\s*\b/, '')}]]]"
end

def replace_img_emoticons(doc)
  doc.css('img.wysihtml5-emoticon-icon').each do |img|
    span = doc.create_element "span"
    span.inner_html = to_emoticon_text("img:" +  img['alt'])
    img.replace span
  end
end

def replace_tinymce_img_emoticons(doc)
  doc.xpath("//img[contains(@src, \"tiny_mce_3/plugins/emotions/img\")]").each do |img|
    span = doc.create_element "span"
    span.inner_html = to_emoticon_text("img_tinymce:" + img['alt'])
    img.replace span
  end
end

def replace_span_emoticons(doc)
  doc.css('span.emoticon').each do |span|
    span.inner_html = to_emoticon_text("span:" + span.inner_html)
  end
end

def replace_emoticons(doc)
  replace_img_emoticons(doc)
  replace_span_emoticons(doc)
  replace_tinymce_img_emoticons(doc)
  doc
end

def replace_emoji(text)
  Emo::ALL.to_a.each do |arr|
    text.gsub! arr[0], to_emoticon_text("emoji:" + arr[1].downcase)
  end
end

def process_content(content)
  text = replace_emoticons(Nokogiri::HTML(content)).text
  replace_emoji(text)
  text
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
count = CSV.read(input_filename, headers: true).length
progress = ProgressBar.new(count)

File.open(output_filename, 'w') do |file|
  CSV.new(file, write_headers: true, headers: headers).tap do |csv|
    CSV.read(input_filename, headers: true).map do |row|
      csv << row.to_a.map do |field|
        field[0] == 'content' ? process_content(field[1])  : field[1]
      end
      progress.increment!
    end
  end
end
