#!/Users/mmochan/.rvm/rubies/ruby-2.2.2/bin/ruby

require 'nokogiri'

class Gpx
  attr_accessor :gpx_names
  attr_reader :file, :doc

  def initialize  file
    @file = file
    @doc = Nokogiri::XML(file)
    @gpx_names = @doc.xpath('//gpx:name', 'gpx' => 'http://www.topografix.com/GPX/1/1')
    @saved = []
    @count = 0
  end

  def parse_name
    puts "Parsing multi track GPX xml data"
    gpx_names.each do |name|
      old_position = save_position name
      if name.content.end_with?("Position 1")
        @count += 1
        @index = @saved.rindex(old_position)
        increment_until_next_position_one(@index, name)
      end
      if @count > 1
        increment_until_next_position_one(@index, name)
        @index += 1
      end

    end
    write_new_file
    close_file
  end

  def increment_until_next_position_one(index, name)
    name.content = "Position " + (index + 1).to_s unless index == 0
  end

  def save_position name 
    @saved << name.content 
    @saved[-2]
  end

  def write_new_file
    puts "Writing new file"
    File.write("./trip_total.gpx", @doc.to_xml)
  end

  def close_file
   puts "Closing file"
   @file.close 
  end
end

gpx = Gpx.new File.open("./trip.gpx")
gpx.parse_name

