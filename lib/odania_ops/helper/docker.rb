module OdaniaOps
	module Helper
		module Docker
			class << self
				def image_tags(image)
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
					$logger.info "Loggin in to private registry #{registry_name}"
					data = $config['docker']
					OdaniaOps::Helper::Shell.execute("docker login --username=#{data['user']} --password=\"#{data['password']}\" --email=#{data['email']} #{registry_url}")
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
