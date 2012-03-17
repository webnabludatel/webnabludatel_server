# encoding: utf-8
require 'csv'

namespace :commissions do
  namespace :load do

    task from_yefimov: :environment do
      filename = ENV["filename"] || ENV["FILENAME"] || "parsed_uiks_1.txt"

      regions = Region.all.inject({}){|element, result|
        result[element.name.downcase] = element
        result
      }

      commissions = {}
      CSV.foreach(filename, quote_char: "'", col_sep: ",") do |row|
        puts "#{row[2]} #{row[4]}"
        coordinates = row[2].split(" ").map{|x| x.to_f }
        region_name = row[1].split(/,\s*/)[1]

        if region_name == "Москва" || region_name == "Санкт-Петербург"
          region_name = "город #{region_name}"
        end

        region_name = region_name.downcase
        number = row[4].match(/№(.+)$/)[1]

        commissions[region_name] ||= {}
        commissions[region_name][number] = { coordinates: coordinates, address: row[3] }
      end

      Commission.includes(:regions).all.each do |commission|
        puts "Searching: #{commission.number} from #{commission.region.name}"

        found_region = commission[commission.region.name.downcase]
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

        write_to.puts line.gsub(/'\s*'\s*$/, "'").gsub(/'\s*'/, "','").gsub(/',\s*/, "','").gsub(/''/, "'")
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