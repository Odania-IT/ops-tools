module OdaniaOps
	module Helper
		module Docker
			class << self
				def image_tags(image)
					return OdaniaOps::Helper::Aws.tags(image) if $config['docker']['use_aws']

					code, data = get("/#{image}/tags/list")
					return [] unless 200.eql? code
					data['tags']
				end

				def remote_tag(image_name_and_tag, target_image_name_and_tag=nil)
					target_image_name_and_tag = image_name_and_tag if target_image_name_and_tag.nil?
					OdaniaOps::Helper::Shell.execute("docker tag #{image_name_and_tag} #{registry_name}/#{target_image_name_and_tag}")
				end

				def push(image_name, tag=nil)
					tag = ":#{tag}" unless tag.nil? or tag.empty?
					OdaniaOps::Helper::Shell.execute("docker push #{registry_name}/#{image_name}#{tag}")
				end

				def login
					data = $config['docker']
					return if data['no_login']

					if $config['docker']['use_aws']
						username, password = OdaniaOps::Helper::Aws.docker_login
					else
						username = data['user']
						password = data['password']
					end

					$logger.info "Login in to private registry #{registry_name}"
					OdaniaOps::Helper::Shell.execute("docker login --username=#{username} --password=\"#{password}\" #{registry_url}")
				end

				def registry_name
					uri = URI.parse $config['docker']['url']
					uri.host
				end

				private

				def auth
					{:username => $config['docker']['user'], :password => $config['docker']['password']}
				end

				def registry_url
					uri = URI.parse $config['docker']['url']
					uri.path = '/v2'
					uri.to_s
				end

				def get(query_url)
					$logger.debug "Query registry: #{registry_url}#{query_url}"
					response = HTTParty.get("#{registry_url}#{query_url}", :basic_auth => auth)
					return response.code, response.parsed_response
				end
			end
		end
	end
end
