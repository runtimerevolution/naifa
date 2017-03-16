module Naifa
  module Plugins
    class S3
      require 'thor'

      class CLI < Thor
        @settings_key = nil
        class << self
          attr_reader :settings_key
        end

        desc "sync <from> <to>", "Syncs from <from> to <to>"
        def sync(from=nil, to=nil)
          config = Naifa::Config.settings[settings_key] || {}

          options = {sync: {}}
          options[:sync][:origin] = from unless from.nil?
          options[:sync][:destination] = to unless to.nil?

          S3.sync(config.fetch(:settings,{}).deep_merge(options))
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
