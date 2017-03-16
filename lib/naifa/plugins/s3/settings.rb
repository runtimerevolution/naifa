module Naifa
  module Plugins
    class S3
      DEFAULT_SETTINGS = {
        environments: {
          production: {
            bucket: 's3://production_bucket_name/'
          },
          staging: {
            bucket: 's3://staging_bucket_name/'
          },
          development: {
            bucket: 's3://development_bucket_name/'
          }
        },
        sync: {
          origin: :staging,
          destination: :development,
          sync_options: ['--delete', '--acl public-read']
        }
      }.with_indifferent_access.freeze
    end
  end
end
