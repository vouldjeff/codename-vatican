require 'ostruct'

APP_CONFIG = OpenStruct.new YAML.load_file("#{Rails.root.to_s}/config/config.yml")[Rails.env]