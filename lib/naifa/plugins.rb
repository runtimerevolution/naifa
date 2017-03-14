module Naifa
  require 'naifa/plugins/postgres'

  module Plugins
    REGISTRY = {
      postgres: {
        cli: Naifa::Plugins::Postgres::CLI,
        description: 'Sync, backup and restore postgres dbs'
      }
    }.with_indifferent_access.freeze

    def registry
      REGISTRY
    end

    module_function :registry
  end
end
