module OdaniaOps
	module Cli
		class Node < Thor
			desc 'exec <command>', 'Run command on nodes'
			option :hosts, :type => :string, :aliases => [:h], :required => true
			option :process, :type => :string, :default => :sequence, :banner => 'Process in sequence or parallel'
			def exec(*args)
				command = args.join(' ')
				on options[:hosts].split(','), in: options[:process].to_sym do |host|
					within '/tmp' do
						result = capture command
						result.split("\n").each do |line|
							info "#{host}: #{line}"
						end
					end
				end
			end
		end
	end
end
