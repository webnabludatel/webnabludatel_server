namespace :plist do

  task load: :environment do

    filename = ENV["filename"] || ENV["FILENAME"]

    result = Plist::parse_xml(filename)

    result.each_key do |key|
      puts "Parsing root section: #{key}"

      section = WatcherChecklistItem.find_or_initialize_by_name key
      section.order = result[key]["order"]
      section.title = result[key]["title"]
      section.save!

      parse_section(section, result[key]["screens"])
    end

  end

  def parse_section(section, screens)
    screens.each_with_index do |item, index|
      if item.has_key? "items"
        puts "Parsing: #{item["title"]}"
        section = section.children.find_or_create_by_title item["title"]
        parse_section(section, item["items"])
      elsif item.has_key? "switch_options"
        puts "Parsing: #{item["name"]}"
        leaf_item = section.children.find_or_initialize_by_name item["name"]
        leaf_item.update_attributes title: item["title"],
                                     lo_value: item["switch_options"]["lo_value"],
                                     hi_value: item["switch_options"]["hi_value"],
                                     lo_text: item["switch_options"]["lo_text"],
                                     hi_text: item["switch_options"]["hi_text"]
      end
    end
  end

end