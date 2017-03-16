module Naifa

  module Plugins
    class Postgres
      require 'naifa/plugins/postgres/cli'
      require 'naifa/plugins/postgres/settings'
      require 'active_support'
      require 'active_support/core_ext/hash/deep_merge'
      require 'active_support/core_ext/object/blank'
      require 'naifa/utils'

      def self.restore(options={})
        filename = options.fetch(:filename, DEFAULT_FILENAME)

        _restore(filename, options)
      end

      def self.backup(options={})
        filename = options.fetch(:filename, DEFAULT_FILENAME)

        _backup(filename, options)
      end

      def self.sync(options={})
        options ||= {}
        filename = options.fetch(:filename, DEFAULT_FILENAME)

        backup_settings = options.fetch(:backup, {})
        restore_settings = options.fetch(:restore, {})
        environments_settings = options.fetch(:environments, {})

        if backup_settings[:environment].blank? ||
            environments_settings[backup_settings[:environment]].blank? ||
            restore_settings[:environment].blank? ||
            environments_settings[restore_settings[:environment]].blank?

          raise Thor::Error, "Sync (Backup and Restore) environments are not defined"
        end

        if environments_settings[backup_settings[:environment]][:type] == :heroku &&
           environments_settings[restore_settings[:environment]][:type] == :heroku

           Heroku::Postgres.sync(
             environments_settings[backup_settings[:environment]][:remote].presence || backup_settings[:environment],
             environments_settings[restore_settings[:environment]][:remote].presence || restore_settings[:environment]
           )
        else
          _backup(filename, options)
          _restore(filename, options)
        end
      end

      def self._backup(filename, options={})
        options ||= {}
        backup_settings = options[:backup]
        environments_settings = options[:environments]

        if backup_settings[:environment].blank? ||
          environments_settings[backup_settings[:environment]].blank?

          raise Thor::Error, "Backup environment is not defined"
        end

        environment_settings = environments_settings[backup_settings[:environment]]

        case environment_settings[:type]
        when :remote
          if environment_settings[:host].blank? ||
              environment_settings[:username].blank? ||
              environment_settings[:database].blank? ||
              (environment_settings[:path].presence || options[:path].presence).blank?

            raise Thor::Error, "Backup remote environment #{backup_settings[:environment]} is not correctly configured"
          end

          command_line = build_backup_command(
            environment_settings[:host],
            environment_settings[:username],
            environment_settings[:database],
            File.join(
              environment_settings[:path].presence || options[:path].presence,
              filename
            )
          )
          Kernel.system(command_line)
        when :local
          if environment_settings[:username].blank? ||
              environment_settings[:database].blank? ||
              (environment_settings[:path].presence || options[:path].presence).blank?

            raise Thor::Error, "Backup local environment #{backup_settings[:environment]} is not correctly configured"
          end

          command_line = build_backup_command(
            'localhost',
            environment_settings[:username],
            environment_settings[:database],
            File.join(
              environment_settings[:path].presence || options[:path].presence,
              filename
            )
          )
          Kernel.system(command_line)
        when :heroku
          if (environment_settings[:path].presence || options[:path].presence).blank?
            raise Thor::Error, "Backup heroku environment #{backup_settings[:environment]} is not correctly configured"
          end

          Heroku::Postgres.backup(
            File.join(
              environment_settings[:path].presence || options[:path].presence,
              filename
            ),
            environment_settings[:remote].presence || backup_settings[:environment]
          )
        when :docker
          if environment_settings[:username].blank? ||
              environment_settings[:database].blank? ||
              (environment_settings[:path].presence || options[:path].presence).blank? ||
              environment_settings[:app_name].blank?

            raise Thor::Error, "Restore docker environment #{backup_settings[:environment]} is not correctly configured"
          end

          command_line = build_backup_command(
            'localhost',
            environment_settings[:username],
            environment_settings[:database],
            File.join(
              environment_settings[:path].presence || options[:path].presence,
              filename
            )
          )
          Utils.docker_compose_exec_command(
            environment_settings[:app_name].presence,
            command_line
          )
        else
          raise Thor::Error, "Backup unsupported type"
        end
      end

      private_class_method :_backup

      def self._restore(filename, options={})
        options ||= {}

        restore_settings = options[:restore]
        environments_settings = options[:environments]

        if restore_settings[:environment].blank? ||
          environments_settings[restore_settings[:environment]].blank?

          raise Thor::Error, "Restore environment is not defined"
        end

        environment_settings = environments_settings[restore_settings[:environment]]

        case environment_settings[:type]
        when :remote
          if environment_settings[:host].blank? ||
              environment_settings[:username].blank? ||
              environment_settings[:database].blank? ||
              (environment_settings[:path].presence || options[:path].presence).blank?

            raise Thor::Error, "Restore remote environment #{restore_settings[:environment]} is not correctly configured"
          end

          command_line = build_restore_command(
            environment_settings[:host],
            environment_settings[:username],
            environment_settings[:database],
            File.join(
              environment_settings[:path].presence || options[:path].presence,
              filename
            )
          )
          Kernel.system(command_line)
        when :local
          if environment_settings[:username].blank? ||
              environment_settings[:database].blank? ||
              (environment_settings[:path].presence || options[:path].presence).blank?

            raise Thor::Error, "Restore local environment #{restore_settings[:environment]} is not correctly configured"
          end

          command_line = build_restore_command(
            'localhost',
            environment_settings[:username],
            environment_settings[:database],
            File.join(
              environment_settings[:path] || options[:path],
              filename
            )
          )
          Kernel.system(command_line)
        when :docker
          if environment_settings[:username].blank? ||
              environment_settings[:database].blank? ||
              (environment_settings[:path].presence || options[:path].presence).blank? ||
              environment_settings[:app_name].blank?

            raise Thor::Error, "Restore docker environment #{restore_settings[:environment]} is not correctly configured"
          end

          command_line = build_restore_command(
            'localhost',
            environment_settings[:username],
            environment_settings[:database],
            File.join(
              environment_settings[:path].presence || options[:path].presence,
              filename
            )
          )
          Utils.docker_compose_exec_command(
            environment_settings[:app_name],
            command_line
          )
        else
          raise Thor::Error, "Restore unsupported type"
        end
      end

      private_class_method :_restore

      def self.build_restore_command(host, username, database, filename)
        "pg_restore --verbose --clean --no-acl --no-owner -h #{host} -U #{username} -d #{database} #{filename}"
      end

      private_class_method :build_restore_command

      def self.build_backup_command(host, username, database, filename)
        "pg_dump -Fc -h #{host} -U #{username} -d #{database} > #{filename}"
      end

      private_class_method :build_backup_command

    end
  end
end
