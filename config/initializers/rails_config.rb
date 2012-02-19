RailsConfig.setup do |config|
  config.const_name = "Settings"
end

Settings.add_source!("#{Rails.root}/config/settings/sensitive_data.yml")
Settings.reload!
