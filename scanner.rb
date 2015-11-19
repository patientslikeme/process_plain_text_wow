require 'csv'
require 'nokogiri'
require 'progress_bar'

class Scanner

  def initialize
    @input_filename = ARGV[0]
    @output_filename = ARGV[1]
    validate_params
  end

  def die(message)
    puts "Usage: bundle exec ruby #{self.class.name.underscore}.rb input_file output_file"
    puts
    abort("Error: #{message}")
  end

  def validate_params
    die('You must specify an input and output file') if @input_filename.nil? || @output_filename.nil?
    die("The input file \"#{@input_filename}\" does not exist") unless File.exists?(@input_filename)
  end


  def process_content
    csv = CSV.read(@input_filename, headers: true)
    progress_bar = ProgressBar.new(csv.length)
    csv.map do |row|
      yield row['content'] unless row['content'].nil?
      progress_bar.increment!
    end
  end

  def write_output(output)
    File.open(@output_filename, 'w') do |file|
      file.puts output
    end
  end

end

class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end
