module Naifa
  class Utils
    def self.download_file(filename, url)
      Kernel.system("curl -o #{filename} #{url}")
    end

    def self.docker_compose_exec_command(app_name, command)
      Kernel.system("docker-compose exec #{app_name} bash -c \"#{command}\"")
    end
  end
end
