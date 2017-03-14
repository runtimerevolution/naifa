module Naifa
  require 'naifa/utils'

  module Plugins
    class Postgres
      require 'active_support/core_ext/hash/deep_merge'

      DEFAULT_SETTINGS = {
        filename: 'db_backup',
        backup: {
          path: './data/db_dumps',
          db_name: '',
          environment: :staging,
          production: {
            type: :heroku
          },
          staging: {
            type: :heroku
          },
          development: {
            type: :docker,
            app_name: 'db',
            database: '',
            username: '\$POSTGRES_USER',
            path: '/db_dumps/'
          }
        },
        restore: {
          path: './data/db_dumps',
          environment: :development,
          staging: {
            type: :heroku
          },
          development: {
            type: :docker,
            app_name: 'db',
            database: '',
            username: '\$POSTGRES_USER',
            path: '/db_dumps/'
          }
        }
      }.with_indifferent_access.freeze

      def self.restore(options={})
        filename = options.fetch(:filename, DEFAULT_SETTINGS[:filename])
        restore_settings = DEFAULT_SETTINGS[:restore].deep_merge(options.fetch(:restore, {}))

        _restore(filename, restore_settings)
      end

      def self.backup(options={})
        filename = options.fetch(:filename, DEFAULT_SETTINGS[:filename])
        backup_settings = DEFAULT_SETTINGS[:backup].deep_merge(options.fetch(:backup, {}))

        _backup(filename, backup_settings)
      end

      def self.sync(options={})
        filename = options.fetch(:filename, DEFAULT_SETTINGS[:filename])

        backup_settings = DEFAULT_SETTINGS[:backup].deep_merge(options.fetch(:backup, {}))
        restore_settings = DEFAULT_SETTINGS[:restore].deep_merge(options.fetch(:restore, {}))

        return false if backup_settings[:environment].nil? ||
                        backup_settings[backup_settings[:environment]].nil? ||
                        restore_settings[:environment].nil? ||
                        restore_settings[restore_settings[:environment]].nil?

        if backup_settings[backup_settings[:environment]][:type] == :heroku &&
           restore_settings[restore_settings[:environment]][:type] == :heroku

           Heroku::Postgres.sync(
             backup_settings[:environment],
             restore_settings[:environment]
           )
        else
          res = _backup(filename, backup_settings)
          _restore(filename, restore_settings) if res
        end
      end

      def self._backup(filename, options)
        environment = options[:environment]
        return false if environment.nil? || options[environment].nil?

        case options[environment][:type]
        when :remote
          command_line = build_backup_command(
            options[environment][:host],
            options[environment][:username] || options[:username],
            options[environment][:database] || options[:database],
            File.join(
              options[environment][:path] || options[:path],
              filename
            )
          )
          Kernel.system(command_line)
        when :local
          command_line = build_backup_command(
            'localhost',
            options[environment][:username] || options[:username],
            options[environment][:database] || options[:database],
            File.join(
              options[environment][:path] || options[:path],
              filename
            )
          )
          Kernel.system(command_line)
        when :heroku
          Heroku::Postgres.backup(
            File.join(
              options[environment][:path] || options[:path],
              filename
            ),
            environment
          )
        end
      end

      private_class_method :_backup

      def self._restore(filename, options={})
        environment = options[:environment]
        return false if environment.nil? || options[environment].nil?

        case options[environment][:type]
        when :remote
          command_line = build_restore_command(
            options[environment][:host],
            options[environment][:username] || options[:username],
            options[environment][:database] || options[:database],
            File.join(
              options[environment][:path] || options[:path],
              filename
            )
          )
          Kernel.system(command_line)
        when :local
          command_line = build_restore_command(
            'localhost',
            options[environment][:username] || options[:username],
            options[environment][:database] || options[:database],
            File.join(
              options[environment][:path] || options[:path],
              filename
            )
          )
          Kernel.system(command_line)
        when :docker
          command_line = build_restore_command(
            'localhost',
            options[environment][:username] || options[:username],
            options[environment][:database] || options[:database],
            File.join(
              options[environment][:path] || options[:path],
              filename
            )
          )
          Utils.docker_compose_exec_command(
            options[environment][:app_name],
            command_line
          )
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
