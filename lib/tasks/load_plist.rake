# encoding: utf-8

#define INPUT_TEXT          0
#define INPUT_NUMBER        1
#define INPUT_DROPDOWN      2
#define INPUT_SWITCH        3
#define INPUT_PHOTO         4
#define INPUT_VIDEO         5
#define INPUT_COMMENT       6
#define INPUT_CONSTANT      7
#define INPUT_EMAIL         8
#define INPUT_PHONE         9

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

  task load_check_list: :environment do
    url = "https://raw.github.com/webnabludatel/watcher-ios/master/ElectionsWatcher/WatcherChecklist.plist"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    puts "Getting: #{url}"
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    response.body.force_encoding('UTF-8')
    parse(response.body, for: :check_list)
  end

  task load_check_list_from_file: :environment do
    parse(ENV["filename"] || ENV["FILENAME"], for: :check_list)
  end

  def parse(filename_or_xml, options = {})
    result = Plist::parse_xml(filename_or_xml)

    check_list = options[:for] == :check_list

    result.each_with_index do |(key, value), index|
      puts "Parsing root section: #{key}"

      node = check_list ? CheckListItem.find_or_initialize_by_name(key) : WatcherAttribute.find_or_initialize_by_name(key)
      node.order = value["order"] || index
      node.title = value["title"]
      node.control_type = value["control"]
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
        leaf.control_type = item["control"]
        leaf.violation_text = item["violation_text"]

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