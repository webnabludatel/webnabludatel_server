# encoding: utf-8

namespace :regions do

  task load: :environment do
    url = "https://raw.github.com/webnabludatel/watcher-ios/master/ElectionsWatcher/WatcherPollingPlace.plist"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    puts "Getting regions from: #{url}"
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    response.body.force_encoding('UTF-8')
    parse(response.body)
  end

  def parse(filename_or_xml)
    result = Plist::parse_xml(filename_or_xml)

    result["ballot_district_info"]["items"].each do |item|
      next unless item["name"] == "district_region"

      item["possible_values"].each_with_index do |region_item, index|
        external_id = region_item["value"]
        name = region_item["title"]

        puts "Parsing: #{external_id}: #{name}"

        region = Region.find_or_initialize_by_external_id external_id
        region.name = name
        region.position = index

        region.save!
      end
    end
  end

end