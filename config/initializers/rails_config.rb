RailsConfig.setup do |config|
  config.const_name = "Settings"
end

Settings.add_source!("#{Rails.root}/config/sensitive_data.yml")
Settings.reload!
