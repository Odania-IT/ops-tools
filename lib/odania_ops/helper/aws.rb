require 'aws-sdk'
require 'base64'

module OdaniaOps
	module Helper
		module Aws
			class << self
				def configure
					::Aws.config.update(
						{
							region: $config['aws']['region'],
							credentials: ::Aws::Credentials.new($config['aws']['access_key_id'], $config['aws']['secret_access_key'])
						}
					)
				end

				def tags(repository_name)
					client = ::Aws::ECR::Client.new(
							{
									region: $config['aws']['region'],
									credentials: ::Aws::Credentials.new($config['aws']['access_key_id'], $config['aws']['secret_access_key'])
							}
					)
					result = []
					response = client.describe_images(repository_name: repository_name)
					response.image_details.each do |aws_image_details|
						result += aws_image_details.image_tags
					end

					result.uniq
				end

				def docker_login
					client = ::Aws::ECR::Client.new(
							{
									region: $config['aws']['region'],
									credentials: ::Aws::Credentials.new($config['aws']['access_key_id'], $config['aws']['secret_access_key'])
							}
					)

					response = client.get_authorization_token
					return Base64.decode64(response.authorization_data[0].authorization_token).split(':')
				end
			end
		end
	end
end
