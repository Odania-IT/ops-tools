module OdaniaOps
	module Cli
		class Docker < Thor
			desc 'build <folder> <image_name> <version_number>', 'Builds the docker image under <folder>'
			def build(folder, image_name, version_number=nil)
				OdaniaOps::Helper::Docker.login

				build_number = version_number.nil? ? get_highest_build_number(image_name) + 1 : version_number.to_i
				build_tag = "v#{build_number}"
				$logger.info "Building version #{build_tag}"

				base_image = get_base_image File.expand_path('Dockerfile', folder)
				$logger.info "Pulling base image #{base_image}"
				OdaniaOps::Helper::Shell.execute("docker pull #{base_image}")

				$logger.info "Building #{image_name}"
				OdaniaOps::Helper::Shell.execute("cd #{folder} && docker build --no-cache --force-rm -t #{image_name}:#{build_tag} .")

				$logger.info "Tagging #{build_tag} as latest"
				OdaniaOps::Helper::Docker.remote_tag "#{image_name}:#{build_tag}"
				OdaniaOps::Helper::Docker.remote_tag "#{image_name}:#{build_tag}", "#{image_name}:latest"

				$logger.info "Pushing #{build_tag}"
				OdaniaOps::Helper::Docker.push image_name, build_tag
				OdaniaOps::Helper::Docker.push image_name, 'latest'
			end

			desc 'base_image_check <folder>', 'Searches for all Dockerfiles under <folder> and looks for the base image'
			def base_image_check(folder)
				OdaniaOps::Helper::Docker.login

				failed_images = []
				Dir.glob("#{folder}/**/Dockerfile").each do |file|
					result = check_latest_base_image file
					failed_images << result unless result
				end

				unless failed_images.empty?
					puts
					puts
					puts 'The following images have newer base images:'
					puts failed_images.inspect
					exit 1
				end
			end

			desc 'push <image_name> <local_image_tag>', 'Pushes the image'
			def push(image_name, local_image_tag)
				OdaniaOps::Helper::Docker.login

				build_number = get_highest_build_number(image_name) + 1
				build_tag = "v#{build_number}"

				$logger.info "Tagging #{build_tag} as latest"
				OdaniaOps::Helper::Docker.remote_tag "#{image_name}:#{local_image_tag}", "#{image_name}:#{build_tag}"
				OdaniaOps::Helper::Docker.remote_tag "#{image_name}:#{local_image_tag}", "#{image_name}:latest"

				$logger.info "Pushing #{build_tag}"
				OdaniaOps::Helper::Docker.push image_name, build_tag
				OdaniaOps::Helper::Docker.push image_name, 'latest'
			end

			private

			def get_highest_build_number(image_name)
				build_numbers = OdaniaOps::Helper::Docker.image_tags(image_name).map { |tag| tag.gsub('v', '').to_i }.sort
				$logger.debug "Build numbers: #{build_numbers.inspect}"
				return 0 if build_numbers.empty?
				build_numbers.pop
			end

			def get_base_image(docker_file)
				contents = File.read(docker_file)
				contents.split("\n").each do |line|
					return line.gsub('FROM', '').strip if line.start_with? 'FROM'
				end

				raise "No base image detected in #{docker_file}"
			end

			def check_latest_base_image(file)
				path = File.dirname file
				image_name = "#{OdaniaOps::Helper::Docker.registry_name}/#{path.split(File::SEPARATOR).last}"
				base_image = get_base_image file
				$logger.info "Found image \"#{image_name}\" with base image \"#{base_image}\""

				$logger.debug "Pulling base image \"#{base_image}\""
				OdaniaOps::Helper::Shell.execute("docker pull #{base_image}")

				$logger.debug "Pulling image \"#{image_name}\""
				OdaniaOps::Helper::Shell.execute("docker pull #{image_name}")

				# Retrieve parent of image
				parent_docker_image = ::Docker::Image.get image_name
				docker_image = ::Docker::Image.get base_image
				maintainer_found = false
				last_entry = nil
				parent_docker_image.history.each do |entry|
					if maintainer_found
						$logger.debug "Detected line before MAINTAINER: #{entry}"
						last_entry = entry
						break
					end
					maintainer_found = true if entry['CreatedBy'].include? 'MAINTAINER'
				end

				if docker_image.history.first.eql? last_entry
					$logger.info "Image #{image_name} already has latest base image"
					return true
				end

				$logger.error "Image #{image_name} has not the newest base image"
				image_name
			end
		end
	end
end
