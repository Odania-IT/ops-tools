require 'odania_ops/version'
require 'thor'
require 'httparty'
require 'logger'
require 'yaml'
require 'deep_merge/rails_compat'
require 'erubis'
require 'active_support/all'
require 'docker-api'

require 'net/ssh/proxy/command'
require 'sshkit'
require 'sshkit/dsl'

BASE_DIR = File.absolute_path File.join(File.dirname(__FILE__), '..') unless defined? BASE_DIR

require_relative 'odania_ops/cli/backup'
require_relative 'odania_ops/cli/config'
require_relative 'odania_ops/cli/docker'
require_relative 'odania_ops/cli/node'
require_relative 'odania_ops/helper/aws'
require_relative 'odania_ops/helper/backup'
require_relative 'odania_ops/helper/config'
require_relative 'odania_ops/helper/docker'
require_relative 'odania_ops/helper/shell'
require_relative 'odania_ops/implementations/backup/mongodb'
require_relative 'odania_ops/implementations/backup/mysql'
require_relative 'odania_ops/implementations/backup/postgres'
require_relative 'odania_ops/implementations/backup/rsync'

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

			desc 'backup', 'Backup helper'
			subcommand 'backup', Backup

			desc 'docker', 'Docker helper'
			subcommand 'docker', Docker

			desc 'config', 'Manage configuration'
			subcommand 'config', Config

			desc 'node', 'Execute commands on nodes'
			subcommand 'node', Node
		end
	end
end
