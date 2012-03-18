# encoding: utf-8
require 'csv'

namespace :commissions do
  namespace :process do

    task fix_dublications: :environment do
      Commission.includes(:user_locations).each do |commission|
        commission.destroy unless commission.user_locations.present?
      end

      Commission.select("DISTINCT number, kind, region_id").each do |commission|
        dubls = Commission.where(number: commission.number, kind: commission.kind, region_id: commission.region_id).where("id != ?", commission.id)
        dubls.each do |dubl|
          dubl.user_locations.update_all(commission_id: commission.id)
          dubl.destroy
        end
      end
    end

    task geo: :environment do
      commissions_without_coordinates = []
      UserLocation.joins(:user).where("users.watcher_status = ?", "approved").where("user_locations.status != ?", "approved").where("user_locations.status != ?", "rejected").includes(:commission).each do |user_location|
        if user_location.commission.latitude.blank? || user_location.commission.longitude.blank?
          puts "Skip commission: #{user_location.commission.id}"
          commissions_without_coordinates << user_location.commission.id
          next
        end
        distance = user_location.distance_to([user_location.commission.latitude, user_location.commission.longitude])
        if distance < 100
          writable_user_location = UserLocation.find user_location.id
          writable_user_location.status = "approved"
          writable_user_location.save!
        else
          puts "UserLocation: <id: #{user_location.id}, user: #{user_location.user_id}, coordinates: #{[user_location.latitude, user_location.longitude]}> - Commission<id: #{user_location.commission.id}, coordinates: #{[user_location.commission.latitude, user_location.commission.longitude]}>: #{distance} "
        end
      end

      puts commissions_without_coordinates
    end

  end

  namespace :load do

    task from_yefimov: :environment do
      filename = ENV["filename"] || ENV["FILENAME"] || "parsed_uiks_1.txt"

      regions = Region.all.inject({}) do |result, element|
        result[element.name.mb_chars.downcase] = element
        result
      end

      commissions = {}
      CSV.foreach(filename, quote_char: "'", col_sep: ",") do |row|
        #puts "#{row[1]} #{row[2]} #{row[3]} #{row[4]}"
        coordinates = row[2].split(" ").map{|x| x.to_f }
        region_name = row[1].split(/,\s*/)[1]

        if region_name == "Москва" || region_name == "Санкт-Петербург"
          region_name = "город #{region_name}"
        end

        next unless region_name

        #region_name = region_name.mb_chars.downcase
        #region_id = regions[region_name].try(:id)
        region_id = Region.where("LOWER(name) = LOWER(?)", region_name)

        unless region_id
          puts "Region #{region_name} not found"
          next
        end

        number_match = row[4].match(/№(.+)$/)
        next unless number_match
        number = number_match[1]

        commissions[region_id] ||= {}
        commissions[region_id][number] = { coordinates: coordinates, address: row[3] }
      end

      puts commissions.keys.inspect

      Commission.includes(:region).all.each do |commission|
        puts "Searching: #{commission.number} from #{commission.region.name}"

        found_region = commission[commission.region_id]
        unless found_region
          puts "\tRegion #{commission.region.name} not found"
          next
        end

        commission_found = found_region[commission.number]
        unless commission_found
          puts "\tCommission #{commission.number} not found"
          next
        end

        commission.address = commission_found[:address]
        commission.latitude = commission_found[:coordinates].first
        commission.longitude = commission_found[:coordinates].second
        commission.save!
      end

    end

    task fix_yefimov: :environment do
      filename = ENV["filename"] || ENV["FILENAME"] || "parsed_uiks.txt"

      write_to = File.open("parsed_uiks_1.txt", "w")
      File.open(filename, 'r').each do |line|

        write_to.puts line.gsub(/'\s*'\s*$/, "'").gsub(/'\s*'/, "','").gsub(/',\s*'/, "','")
      end

      write_to.close
    end

    task simple_csv: :environment do

      filename = ENV["filename"] || ENV["FILENAME"]
      skip_geocode = ENV["skip_geocode"] && ENV["skip_geocode"].downcase
      force = set_force

      Commission.skip_callback(:validations, :after, :geocode) if skip_geocode && skip_geocode == "true"

      CSV.foreach(filename, :quote_char => '"', :col_sep =>',', :row_sep =>:auto) do |row|
        next if row[0] == "id"

        row[1].gsub!(/^0+/,'')

        commission = Commission.find_by_number row[1]
        if commission && force
         puts "Updating commission #{row[1]}: #{row[4]}"
         commission.address = row[4]
         commissions.status = "approved"
         commission.save!
        elsif commission.nil?
         puts "Creating commission: #{row[1]}, #{row[4]}"
         Commission.create! number: row[1], address: row[4], status: "approved"
        else
          puts "Skipping commission: #{row[1]}"
        end
      end

      Commission.set_callback(:validations, :after, :geocode) if skip_geocode && skip_geocode == "true"

    end

  end

  def set_force
    force = ENV["force"] || ENV["FORCE"]
    force = force && force.downcase
    force == "force" || force == "true"
  end
end