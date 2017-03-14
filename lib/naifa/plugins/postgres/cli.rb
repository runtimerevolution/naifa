module Naifa
  module Plugins
    class Postgres
      require 'thor'

      class CLI < Thor
        @settings_key = nil
        class << self
          attr_reader :settings_key
        end

        desc "sync <from> <to>", "Syncs from <from> to <to>"
        def sync(from=nil, to=nil)
          config = Naifa::Config.settings[settings_key] || {}

          options = {backup: {}, restore: {}}
          options[:backup][:environment] = from unless from.nil?
          options[:restore][:environment] = to unless to.nil?

          Postgres.sync(config.fetch(:settings,{}).deep_merge(options))
        end

        desc "backup <from>", "Backup from <from>"
        def backup(from=nil)
          config = Naifa::Config.settings[settings_key] || {}
          options = from.nil? ? {} : {backup: {environment: from}}

          Postgres.backup(config.fetch(:settings,{}).deep_merge(options))
        end

        desc "restore <to>", "Restore to <to>"
        def restore(to=nil)
          config = Naifa::Config.settings[settings_key] || {}
          options = to.nil? ? {} : {restore: {environment: to}}

          Postgres.restore(config.fetch(:settings,{}).deep_merge(options))
        end

        no_commands do
          def settings_key
            self.class.settings_key
          end
        end
      end
    end
  end
end
