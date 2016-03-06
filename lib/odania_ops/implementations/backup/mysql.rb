module OdaniaOps
	module Implementations
		module Backup
			class Mysql
				attr_accessor :template, :host, :opts

				def initialize(host, opts)
					self.host = host
					self.opts = opts
					self.template = File.new(File.join(BASE_DIR, 'templates', 'backup', 'mysql.rb.erb')).read
				end

				def render
					Erubis::Eruby.new(self.template).result(binding)
				end

				def write(target_file)
					File.write(target_file, self.render)
					`chmod +x #{target_file}`
				end
			end
		end
	end
end
