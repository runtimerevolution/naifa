# Naifa

## Description

Naifa is a tool aimed at providing a collection of commands that simplify the development workflow.
This is still a WIP and it may have some rough edges, so please be sure to test it in a safe environment before using it. We are not responsible for any data that you may loose while using it.
This also means that features and even commands may changes in the future, so please read the [changelog](CHANGELOG.md) on every update to be aware of the changes and please test it before using it with production data/environments.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'naifa'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install naifa

After the gem is installed run the following command to initialize the configuration file in your project

    $ naifa init

This command will create a file .naifa in your project folder with the default settings as if you didn't had a settings file.

You should now update some of the settings to meet your app configurations.

## Usage

The .naifa file contains settings that will have an influence in the available command options.

The current default settings are the following:
```
---
version: 1.1
db:
  plugin: :postgres
  settings:
    filename: db_backup
    path: "./data/db_dumps"
    environments:
      production:
        type: :heroku
      staging:
        type: :heroku
      development:
        type: :docker
        app_name: db
        database: ''
        username: "\\$POSTGRES_USER"
        path: "/db_dumps/"
    backup:
      environment: :staging
    restore:
      environment: :development
```

Taking this into account, you'll be able to run the following commands

### sync

```
$ naifa db sync
```

This will sync your staging postgres db in heroku to your development postgres in docker

```
$ naifa db sync production
```

This will sync your production postgres db in heroku to your development postgres in docker

### backup

```
$ naifa db backup
```

This will backup your staging postgres db in heroku to './data/db_dumps/db_backup'

```
$ naifa db backup production
```

This will backup your postgres postgres db in heroku to './data/db_dumps/db_backup'

### restore

```
$ naifa db restore
```

This will restore the backup in './data/db_dumps/db_backup' to your development postgres

## Advanced

Imagine that you have 2 databases with different settings and configurations
You can update you configuration file by adding another entry like in the example bellow

```
---
version: 1.1
db:
  plugin: :postgres
  settings:
    filename: db_backup
    path: "./data/db_dumps"
    environments:
      production:
        type: :heroku
      staging:
        type: :heroku
      development:
        type: :docker
        app_name: db
        database: ''
        username: "\\$POSTGRES_USER"
        path: "/db_dumps/"
    backup:
      environment: :staging
    restore:
      environment: :development
db_local:
  plugin: :postgres
  settings:
    filename: db_backup
    path: "./data/db_dumps"
    environments:
      production:
        type: :heroku
      staging:
        type: :heroku
      development:
        type: :local
        database: dev_db1
        username: "\\$POSTGRES_USER"
        password: pass
        path: "/db_dumps/"
    backup:
      environment: :staging
    restore:
      environment: :development
```

This configuration will allow you to run the commands like this:

```
$ naifa db sync
$ naifa db_local sync
```

## Roadmap

* Add tests
* Add documentation
* Add AWS S3 sync between environments
* Add MySQL sync, backup and restore
* Add MongoDB sync, backup and restore
* -Rethink the commands to more dynamic depending on the plugin-
* Add logs and better error handling

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/runtimerevolution/naifa.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
