require 'csv'

namespace :comissions do
  namespace :load do

    task simple_csv: :environment do

      filename = ENV["filename"] || ENV["FILENAME"]
      skip_geocode = ENV["skip_geocode"] && ENV["skip_geocode"].downcase
      force = set_force

      Comission.skip_callback(:validations, :after, :geocode) if skip_geocode && skip_geocode == "true"

      CSV.foreach(filename, :quote_char => '"', :col_sep =>',', :row_sep =>:auto) do |row|
        next if row[0] == "id"

        row[0].gsub!(/^0+/,'')

        comission = Comission.find_by_number row[1]
        if comission && force
         puts "Updating comission #{row[1]}: #{row[4]}"
         comission.address = row[4]
         comissions.status = "approved"
         comission.save!
        elsif comission.nil?
         puts "Creating comission: #{row[1]}, #{row[4]}"
         Comission.create! number: row[1], address: row[4], status: "approved"
        else
          puts "Skipping comission: #{row[1]}"
        end
      end

      Comission.set_callback(:validations, :after, :geocode) if skip_geocode && skip_geocode == "true"

    end

  end

  def set_force
    force = ENV["force"] || ENV["FORCE"]
    force = force && force.downcase
    force == "force" || force == "true"
  end
end