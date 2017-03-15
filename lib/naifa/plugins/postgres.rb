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

        _restore(filename, options[:restore])
      end

      def self.backup(options={})
        filename = options.fetch(:filename, DEFAULT_FILENAME)

        _backup(filename, options[:backup])
      end

      def self.sync(options={})
        options ||= {}
        filename = options.fetch(:filename, DEFAULT_FILENAME)

        backup_settings = options.fetch(:backup, {})
        restore_settings = options.fetch(:restore, {})

        if backup_settings[:environment].blank? ||
            backup_settings[backup_settings[:environment]].blank? ||
            restore_settings[:environment].blank? ||
            restore_settings[restore_settings[:environment]].blank?

          raise Thor::Error, "Sync (Backup and Restore) environments are not defined"
        end

        if backup_settings[backup_settings[:environment]][:type] == :heroku &&
           restore_settings[restore_settings[:environment]][:type] == :heroku

           Heroku::Postgres.sync(
             backup_settings[:environment],
             restore_settings[:environment]
           )
        else
          _backup(filename, backup_settings)
          _restore(filename, restore_settings)
        end
      end

      def self._backup(filename, options={})
        options ||= {}
        environment = options[:environment]
        raise Thor::Error, "Backup environment is not defined" if environment.nil? || options[environment].nil?

        case options[environment][:type]
        when :remote
          if options[environment][:host].blank? ||
              (options[environment][:username].presence || options[:username].presence).blank? ||
              (options[environment][:database].presence || options[:database].presence).blank? ||
              (options[environment][:path].presence || options[:path].presence).blank?

            raise Thor::Error, "Backup remote environment #{environment} is not correctly configured"
          end

          command_line = build_backup_command(
            options[environment][:host],
            options[environment][:username].presence || options[:username].presence,
            options[environment][:database].presence || options[:database].presence,
            File.join(
              options[environment][:path].presence || options[:path].presence,
              filename
            )
          )
          Kernel.system(command_line)
        when :local
          if (options[environment][:username].presence || options[:username].presence).blank? ||
              (options[environment][:database].presence || options[:database].presence).blank? ||
              (options[environment][:path].presence || options[:path].presence).blank?

            raise Thor::Error, "Backup local environment #{environment} is not correctly configured"
          end

          command_line = build_backup_command(
            'localhost',
            options[environment][:username].presence || options[:username].presence,
            options[environment][:database].presence || options[:database].presence,
            File.join(
              options[environment][:path].presence || options[:path].presence,
              filename
            )
          )
          Kernel.system(command_line)
        when :heroku
          if (options[environment][:path].presence || options[:path].presence).blank?
            raise Thor::Error, "Backup heroku environment #{environment} is not correctly configured"
          end

          Heroku::Postgres.backup(
            File.join(
              options[environment][:path].presence || options[:path].presence,
              filename
            ),
            environment
          )
        else
          raise Thor::Error, "Backup unsupported type"
        end
      end

      private_class_method :_backup

      def self._restore(filename, options={})
        options ||= {}
        environment = options[:environment]
        raise Thor::Error, "Restore environment is not defined" if environment.nil? || options[environment].nil?

        case options[environment][:type]
        when :remote
          if options[environment][:host].blank? ||
              (options[environment][:username].presence || options[:username].presence).blank? ||
              (options[environment][:database].presence || options[:database].presence).blank? ||
              (options[environment][:path].presence || options[:path].presence).blank?

            raise Thor::Error, "Restore remote environment #{environment} is not correctly configured"
          end

          command_line = build_restore_command(
            options[environment][:host],
            options[environment][:username].presence || options[:username].presence,
            options[environment][:database].presence || options[:database].presence,
            File.join(
              options[environment][:path].presence || options[:path].presence,
              filename
            )
          )
          Kernel.system(command_line)
        when :local
          if (options[environment][:username].presence || options[:username].presence).blank? ||
              (options[environment][:database].presence || options[:database].presence).blank? ||
              (options[environment][:path].presence || options[:path].presence).blank?

            raise Thor::Error, "Restore local environment #{environment} is not correctly configured"
          end

          command_line = build_restore_command(
            'localhost',
            options[environment][:username].presence || options[:username].presence,
            options[environment][:database].presence || options[:database].presence,
            File.join(
              options[environment][:path] || options[:path],
              filename
            )
          )
          Kernel.system(command_line)
        when :docker
          if (options[environment][:username].presence || options[:username].presence).blank? ||
              (options[environment][:database].presence || options[:database].presence).blank? ||
              (options[environment][:path].presence || options[:path].presence).blank? ||
              options[environment][:app_name].blank?

            raise Thor::Error, "Restore docker environment #{environment} is not correctly configured"
          end

          command_line = build_restore_command(
            'localhost',
            options[environment][:username].presence || options[:username].presence,
            options[environment][:database].presence || options[:database].presence,
            File.join(
              options[environment][:path].presence || options[:path].presence,
              filename
            )
          )
          Utils.docker_compose_exec_command(
            options[environment][:app_name].presence,
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
