#!/Users/mmochan/.rvm/rubies/ruby-2.2.2/bin/ruby

require 'nokogiri'

class Gpx
  attr_accessor :gpx_name_nodes, :saved, :count

  def initialize  file
    @doc = Nokogiri::XML(file)
    @gpx_name_nodes = @doc.xpath('//gpx:name', 'gpx' => 'http://www.topografix.com/GPX/1/1')
    @saved = []
    @count = 0
  end

  def parse_name
    puts "Parsing multi track GPX xml data"
    gpx_name_nodes.each do |node|
      old_position = save_position node
      if node.content.end_with?("Position 1")
        @count += 1
        @index = saved.rindex(old_position)
        increment_until_next_position_one(@index, node)
      end
      if @count > 1
        increment_until_next_position_one(@index, node)
        @index += 1
      end
    end
    write_new_file
  end

  def increment_until_next_position_one(index, node)
    node.content = "Position " + (index + 1).to_s unless index == 0
  end

  def save_position node 
    saved << node.content 
    saved[-2]
  end

  def write_new_file
    puts "Writing new file"
    File.write("./trip_total.gpx", @doc.to_xml)
  end
end

gpx = Gpx.new File.open("./trip.gpx")
gpx.parse_name

