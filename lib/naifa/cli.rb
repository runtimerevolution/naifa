module Naifa
  require 'thor'
  class CLI < Thor

    desc "init <filename>", "Initializes <filename=.naifa> config file with all default settings"
    def init(filename='.naifa')
      File.write(filename, Naifa::Config.generate_full_default_settings.to_h.to_yaml)
    end

    desc "sync <what> <from> <to>", "Syncs <what> from <from> to <to>"
    def sync(what, from=nil, to=nil)
      what_config = Naifa::Config.settings[what.to_sym] || {}

      options = {backup: {}, restore: {}}
      options[:backup][:environment] = from unless from.nil?
      options[:restore][:environment] = to unless to.nil?

      case what_config[:plugin]
      when :postgres
        Naifa::Plugins::Postgres.sync(what_config.fetch(:settings,{}).deep_merge(options))
      end
    end

    desc "backup <what> <from>", "Backup <what> from <from>"
    def backup(what, from=nil)
      what_config = Naifa::Config.settings[what.to_sym] || {}
      options = from.nil? ? {} : {backup: {environment: from}}

      case what_config[:plugin]
      when :postgres
        Naifa::Plugins::Postgres.backup(what_config.fetch(:settings,{}).deep_merge(options))
      end
    end

    desc "restore <what> <to>", "Restore <what> to <to>"
    def restore(what, to=nil)
      what_config = Naifa::Config.settings[what.to_sym] || {}
      options = to.nil? ? {} : {restore: {environment: to}}

      case what_config[:plugin]
      when :postgres
        Naifa::Plugins::Postgres.restore(what_config.fetch(:settings,{}).deep_merge(options))
      end
    end
  end
end
