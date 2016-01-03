module OdaniaOps
	module Helper
		module Config
			class << self
				def load_config(folder)
					config_file = nil
					begin
						config_file = retrieve_config_folder '/etc'
					rescue RuntimeError
						config_file = retrieve_config_folder folder
					end

					$logger.debug "Loading config file #{config_file}"
					$config = YAML.load_file(config_file)
					$logger.debug $config.inspect
				end

				def retrieve_config_folder(start_folder)
					folder = start_folder
					loop do
						break unless File.directory?(folder)

						config_file = File.expand_path('ops-config.yml', folder)
						return config_file if File.exists? config_file

						next_folder = File.expand_path('..', folder)

						break if next_folder.eql?(folder)
						folder = next_folder
					end

					raise "No configuration found! Looking in #{start_folder} and above."
				end
			end
		end
	end
end