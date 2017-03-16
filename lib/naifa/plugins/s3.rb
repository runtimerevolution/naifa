module Naifa

  module Plugins
    class S3
      require 'naifa/plugins/s3/cli'
      require 'naifa/plugins/s3/settings'
      require 'active_support'
      require 'active_support/core_ext/hash/deep_merge'
      require 'active_support/core_ext/object/blank'
      require 'naifa/utils'

      def self.sync(options={})
        options ||= {}

        sync_settings = options[:sync]
        environments_settings = options[:environments]

        if sync_settings.blank? ||
          sync_settings[:origin].blank? ||
          sync_settings[:destination].blank?

          raise Thor::Error, "Sync settings are not defined"
        end

        origin = sync_settings[:origin]
        destination = sync_settings[:destination]

        if environments_settings.blank? ||
          environments_settings[origin].blank? || environments_settings[origin][:bucket].blank? ||
          environments_settings[destination].blank? || environments_settings[destination][:bucket].blank?

          raise Thor::Error, "Sync environments not set"
        end

        command = build_sync_command(
                    environments_settings[origin][:bucket],
                    environments_settings[destination][:bucket],
                    sync_settings.fetch(:sync_options, [])
                  )

        Kernel.system(command)
      end

      def self.build_sync_command(from_bucket, to_bucket, sync_options=[])
        command = "aws s3 sync #{from_bucket} #{to_bucket}"
        command << " #{sync_options.join(' ')}" if sync_options.present?
        command
      end
    end
  end
end
