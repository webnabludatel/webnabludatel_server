require 'csv'

namespace :commissions do
  namespace :load do

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