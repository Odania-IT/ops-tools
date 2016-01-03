require 'odania_ops/version'
require 'thor'
require 'httparty'
require 'logger'
require 'yaml'
require 'deep_merge/rails_compat'

require_relative 'odania_ops/cli/config'
require_relative 'odania_ops/cli/docker'
require_relative 'odania_ops/helper/config'
require_relative 'odania_ops/helper/docker'
require_relative 'odania_ops/helper/shell'

# Setup logger
$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO

# Load Config
OdaniaOps::Helper::Config.load_config(__FILE__)

module OdaniaOps
	module Cli
		class Application < Thor
			desc 'docker', 'Docker helper'
			subcommand 'docker', Docker

			desc 'config', 'Manage configuration'
			subcommand 'config', Config
		end
	end
end
