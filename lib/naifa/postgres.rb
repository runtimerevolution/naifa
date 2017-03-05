module Naifa
  require 'naifa/utils'

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
      _restore(filename, options.fetch(:restore, {}))
    end

    def self.backup(options={})
      filename = options.fetch(:filename, DEFAULT_SETTINGS[:filename])
      _backup(filename, options.fetch(:backup, {}))
    end

    def self.sync(options={})
      filename = options.fetch(:filename, DEFAULT_SETTINGS[:filename])
      res = _backup(filename, options.fetch(:backup, {}))
      _restore(filename, options.fetch(:restore, {})) if res
    end

    def self._backup(filename, options={})
      options = DEFAULT_SETTINGS[:backup].deep_merge(options)

      environment = options[:environment]
      return false if options[environment].nil?

      case options[environment][:type]
      when :local
        command_line = build_backup_command(
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
          environment: environment
        )
      end
    end

    private_class_method :_backup

    def self._restore(filename, options={})
      options = DEFAULT_SETTINGS[:restore].deep_merge(options)

      environment = options[:environment]
      return false if options[environment].nil?

      case options[environment][:type]
      when :local
        command_line = build_restore_command(
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

    def self.build_restore_command(username, database, filename)
      "pg_restore --verbose --clean --no-acl --no-owner -h localhost -U #{username} -d #{database} #{filename}"
    end

    def self.build_backup_command(username, database, filename)
      "pg_dump -Fc -h localhost -U #{username} -d #{database} > #{filename}"
    end

    private_class_method :build_restore_command
  end
end
