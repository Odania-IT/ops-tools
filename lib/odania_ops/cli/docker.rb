module OdaniaOps
	module Cli
		class Docker < Thor
			desc 'build <folder> <image_name> <version_number>', 'Builds the docker image under <folder>'
			def build(folder, image_name, version_number=nil)
				OdaniaOps::Helper::Docker.login

				build_number = version_number.nil? ? get_highest_build_number(image_name) + 1 : version_number.to_i
				build_tag = "v#{build_number}"
				$logger.info "Building version #{build_tag}"

				base_image = get_base_image(folder)
				$logger.info "Pulling base image #{base_image}"
				OdaniaOps::Helper::Shell.execute("docker pull #{base_image}")

				$logger.info "Building #{image_name}"
				OdaniaOps::Helper::Shell.execute("cd #{folder} && docker build -t #{image_name}:#{build_tag} .")

				$logger.info "Tagging #{build_tag} as latest"
				OdaniaOps::Helper::Docker.remote_tag "#{image_name}:#{build_tag}"
				OdaniaOps::Helper::Docker.remote_tag "#{image_name}:#{build_tag}", "#{image_name}:latest", true

				$logger.info "Pushing #{build_tag}"
				OdaniaOps::Helper::Docker.push image_name
			end

			private

			def get_highest_build_number(image_name)
				build_numbers = OdaniaOps::Helper::Docker.image_tags(image_name).map { |tag| tag.gsub('v', '').to_i }.sort
				puts build_numbers.inspect
				return 0 if build_numbers.empty?
				build_numbers.pop
			end

			def get_base_image(folder)
				docker_file = File.expand_path 'Dockerfile', folder
				contents = File.read(docker_file)
				contents.split("\n").each do |line|
					return line.gsub('FROM', '').strip if line.start_with? 'FROM'
				end

				raise "No base image detected in #{docker_file}"
			end
		end
	end
end