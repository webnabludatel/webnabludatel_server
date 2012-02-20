namespace :plist do

  task load: :environment do

    filename = ENV["filename"] || ENV["FILENAME"]

    result = Plist::parse_xml(filename)

    result.each_with_index do |(key, value), index|
      puts "Parsing root section: #{key}"

      section = WatcherChecklistItem.find_or_initialize_by_name key
      section.order = value["order"] || index
      section.title = value["title"]
      section.save!

      parse_section(section, value["screens"] || value["items"])
    end

  end

  def parse_section(section, items)
    items.each_with_index do |item, index|
      if item.has_key? "items"
        puts "Parsing: #{item["title"]}"

        section = section.children.find_or_initialize_by_title item["title"]
        section.order = index
        section.save!

        parse_section(section, item["items"])
      else
        puts "Parsing: #{item["name"]}"

        leaf_item = section.children.find_or_initialize_by_name item["name"]
        leaf_item.title = item["title"]
        leaf_item.order = index

        if item.has_key? "switch_options"
          leaf_item.attributes = {
                                    lo_value: item["switch_options"]["lo_value"],
                                    hi_value: item["switch_options"]["hi_value"],
                                    lo_text: item["switch_options"]["lo_text"],
                                    hi_text: item["switch_options"]["hi_text"]
                                  }
        end

        leaf_item.save!
      end
    end
  end

end