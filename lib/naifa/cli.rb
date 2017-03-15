module Naifa
  require 'thor'

  module PluginsCLI
    Naifa::Config.settings.each do |sub_comm, settings|
      class_eval <<-EORUBY
        class #{sub_comm.to_s.capitalize} < #{Naifa::Plugins::registry[settings[:plugin]][:cli].to_s}
          @settings_key = :#{sub_comm}
        end
      EORUBY
    end
  end

  class CLI < Thor

    desc "init <filename>", "Initializes <filename=.naifa> config file with all default settings"
    def init(filename='.naifa')
      File.write(filename, Naifa::Config.generate_example_settings.to_h.to_yaml)
    end

    Naifa::Config.settings.each do |sub_comm, settings|
      class_eval <<-EORUBY
        desc "#{sub_comm} SUBCOMMAND ...ARGS", "#{Naifa::Plugins::registry[settings[:plugin]][:description].to_s}"
        subcommand "#{sub_comm}", PluginsCLI::#{sub_comm.to_s.capitalize}
      EORUBY
    end
  end
end
