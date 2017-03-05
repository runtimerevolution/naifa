module Naifa
  require 'naifa/utils'

  class Heroku
    class Postgres
      def self.backup(filename, environment: :staging)
        res = Kernel.system(build_capture_command(environment))
        Utils.download_file(filename, "`#{build_public_url_command(environment)}`") if res
      end

      def self.build_public_url_command(environment)
        "heroku pg:backups public-url -r #{environment}"
      end

      def self.build_capture_command(environment)
        "heroku pg:backups capture -r #{environment}"
      end
    end
  end
end
