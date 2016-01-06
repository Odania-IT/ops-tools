require 'odania_ops/version'
require 'thor'
require 'httparty'
require 'logger'
require 'yaml'
require 'deep_merge/rails_compat'
require 'active_support/all'
require 'docker-api'

require_relative 'odania_ops/cli/config'
require_relative 'odania_ops/cli/docker'
require_relative 'odania_ops/helper/config'
require_relative 'odania_ops/helper/docker'
require_relative 'odania_ops/helper/shell'

# Setup logger
$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO

# Load Config
OdaniaOps::Helper::Config.load_config(File.dirname(__FILE__))

module OdaniaOps
	module Cli
		class Application < Thor
			class_option :log_level, :default => 'INFO', :aliases => '-l', enum: %w(INFO DEBUG ERROR WARN UNKNOWN FATAL), desc: 'Set Log Level'

			def initialize(*args)
				super

				$logger.level = "Logger::#{options['log_level']}".constantize
			end

			desc 'docker', 'Docker helper'
			subcommand 'docker', Docker

			desc 'config', 'Manage configuration'
			subcommand 'config', Config
		end
	end
end
