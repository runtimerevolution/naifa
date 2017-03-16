module Naifa
  require 'naifa/utils'

  class Heroku
    class Postgres
      def self.backup(filename, environment=:staging)
        res = capture(environment)
        Utils.download_file(filename, "`#{build_public_url_command(environment)}`") if res
      end

      def self.sync(from=:production, to=:staging)
        res = capture(from)
        Kernel.system(build_restore_command("`#{build_public_url_command(from)}`", to)) if res
      end

      def self.capture(environment=:staging)
        Kernel.system(build_capture_command(environment))
      end

      def self.restore(environment=:staging)
        Kernel.system(build_capture_command(environment))
      end

      def self.build_restore_command(backup_url, environment)
        "heroku pg:backups:restore #{backup_url} DATABASE_URL -r #{environment}"
      end

      def self.build_public_url_command(environment)
        "heroku pg:backups public-url -r #{environment}"
      end

      private_class_method :build_public_url_command

      def self.build_capture_command(environment)
        "heroku pg:backups capture -r #{environment}"
      end

      private_class_method :build_capture_command
    end
  end
end
