module Naifa
  class Config
    require 'yaml'
    require 'active_support/core_ext/hash/indifferent_access'

    SETTINGS_VERSION = 1.1
    DEFAULT_SETTINGS = {
      db: {
        :plugin => :postgres
      },
      s3: {
        :plugin => :s3
      }
    }.with_indifferent_access.freeze

    def self.settings
      @settings ||= begin
        loaded_settings = YAML.load(File.read('.naifa')).with_indifferent_access if File.exists?('.naifa')
        if !loaded_settings.nil? && loaded_settings.delete(:version) != SETTINGS_VERSION
          raise 'Configuration file version is not supported. Please upgrade!'
        end
        loaded_settings
      end || {}
    end

    def self.generate_example_settings
      full_settings = {'version' => SETTINGS_VERSION}.with_indifferent_access
        .merge(DEFAULT_SETTINGS)
      full_settings[:db][:settings] = Naifa::Plugins::Postgres::DEFAULT_SETTINGS
      full_settings[:s3][:settings] = Naifa::Plugins::S3::DEFAULT_SETTINGS
      full_settings.to_hash
    end

    def self.sub_commands
      settings.keys
    end
  end
end
