module OdaniaOps
	module Cli
		class Backup < Thor
			desc 'execute <options>', 'Executes a backup'
			option :type, :type => :string, :required => true
			option :host, :type => :string, :required => true
			option :host_user, :type => :string, :required => true
			option :target_host, :type => :string, :required => true
			option :target_type, :type => :string, :required => true
			option :target_user, :type => :string, :required => true
			option :target_password, :type => :string, :required => true
			option :jumpbox, :type => :string

			def execute(opts=nil)
				@type = options[:type]
				$logger.info "Starting backup [#{@type}] #{options[:host]} -> [#{options[:target_type]}] #{options[:target_host]} (Jumpbox: #{options[:jumpbox]})"
				opts = opts.nil? ? {} : JSON.parse(opts)

				# Detect implementation
				backup_script_file = "/tmp/#{Time.now.to_i}_backup.rb"
				clazz = "OdaniaOps::Implementations::Backup::#{@type}".constantize.new options[:host], opts
				clazz.write backup_script_file

				set_jump_host(options[:jumpbox]) unless options[:jumpbox].nil?

				server_host = options[:host_user].nil? ? options[:host] : "#{options[:host_user]}@#{options[:host]}"
				on server_host, in: :sequence do |host|
					within '/tmp' do
						server_backup_file = "/tmp/#{@type}_backup.rb"
						upload! backup_script_file, server_backup_file
						result = capture "sudo #{server_backup_file}"
						$logger.info result
					end
				end

				$logger.info "Finished backup [#{@type}] #{options[:host]} -> [#{options[:target_type]}] #{options[:target_host]} (Jumpbox: #{options[:jumpbox]})"
			end

			private

			def set_jump_host(host)
				SSHKit::Backend::Netssh.configure do |ssh|
					ssh.ssh_options = {
						forward_agent: true,
						auth_methods: %w(publickey),
						proxy: Net::SSH::Proxy::Command.new("ssh #{host} -W %h:%p")
					}
				end
			end
		end
	end
end
