module Naifa
  module Plugins
    class Postgres
      DEFAULT_FILENAME = 'db_backup'.freeze
      DEFAULT_SETTINGS = {
        filename: DEFAULT_FILENAME,
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
    end
  end
end
