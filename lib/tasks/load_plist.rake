# encoding: utf-8

namespace :plist do

  task load: :environment do
    url_base = "https://raw.github.com/webnabludatel/watcher-ios/master/ElectionsWatcher/"
    files = %W(WatcherChecklist.plist WatcherProfile.plist WatcherSOS.plist WatcherSettings.plist WatcherPollingPlace.plist)

    files.each do |filename|
      url = "#{url_base}#{filename}"
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      puts "Getting: #{url}"
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      response.body.force_encoding('UTF-8')
      parse(response.body)
    end
  end

  task load_from_file: :environment do
    parse(ENV["filename"] || ENV["FILENAME"])
  end

  def parse(filename_or_xml)
    result = Plist::parse_xml(filename_or_xml)

    result.each_with_index do |(key, value), index|
      puts "Parsing root section: #{key}"

      node = WatcherAttribute.find_or_initialize_by_name key
      node.order = value["order"] || index
      node.title = value["title"]
      node.save!

      parse_node(node, value["screens"] || value["items"])
    end
  end

  def parse_node(node, items)
    items.each_with_index do |item, index|
      if item.has_key? "items"
        puts "Parsing: #{item["title"]}"

        current_node = node.children.find_or_initialize_by_title item["title"]
        current_node.order = index
        current_node.save!

        parse_node(current_node, item["items"])
      else
        puts "Parsing: #{item["name"]}"

        leaf = node.children.find_or_initialize_by_name item["name"]
        leaf.title = item["title"]
        leaf.order = index

        if item.has_key? "switch_options"
          leaf.attributes = {
                                    lo_value: item["switch_options"]["lo_value"],
                                    hi_value: item["switch_options"]["hi_value"],
                                    lo_text: item["switch_options"]["lo_text"],
                                    hi_text: item["switch_options"]["hi_text"]
                                  }
        end

        leaf.save!
      end
    end
  end

end