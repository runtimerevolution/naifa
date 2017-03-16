module Naifa
  require 'naifa/plugins/postgres'
  require 'naifa/plugins/s3'

  module Plugins
    REGISTRY = {
      postgres: {
        cli: Naifa::Plugins::Postgres::CLI,
        description: 'Sync, backup and restore postgres dbs'
      },
      s3: {
        cli: Naifa::Plugins::S3::CLI,
        description: 'Syncs s3 buckets'
      }
    }.with_indifferent_access.freeze

    def registry
      REGISTRY
    end

    module_function :registry
  end
end
