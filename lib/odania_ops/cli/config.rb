module OdaniaOps
	module Cli
		class Config < Thor
			desc 'init <folder>', 'Initializes a configuration file under <folder>. If not set "/etc" is used'

			def init(folder='/etc')
				config_file = File.expand_path 'ops-config.yml', folder
				current_config = default_config.deeper_merge! $config

				$logger.info "Writting new configuration to #{config_file}"
				File.open(config_file, 'w') {|f| f.write current_config.to_yaml }
			end

			private

			def default_config
				{
					'docker' => {
						'email' => '',
						'user' => '',
						'password' => '',
						'url' => ''
					}
				}
			end
		end
	end
end