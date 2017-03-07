module Naifa
  class Config
    require 'yaml'
    require 'active_support/core_ext/hash/indifferent_access'

    SETTINGS_VERSION = 1.0
    DEFAULT_SETTINGS = {
      db: {
        :plugin => :postgres
      }
    }.with_indifferent_access.freeze

    def self.settings
      @settings ||= begin
        loaded_settings = YAML.load(File.read('.naifa')).with_indifferent_access if File.exists?('.naifa')
        if !loaded_settings.nil? && loaded_settings[:version] != SETTINGS_VERSION
          raise 'Configuration file version is not supported. Please upgrade!'
        end
        loaded_settings
      end || DEFAULT_SETTINGS
    end

    def self.generate_full_default_settings
      full_settings = {'version' => SETTINGS_VERSION}.with_indifferent_access
        .merge(DEFAULT_SETTINGS)
      full_settings[:db][:settings] = Naifa::Postgres::DEFAULT_SETTINGS
      full_settings.to_hash
    end

    def self.sub_commands
      settings.keys
    end
  end
end
