module OdaniaOps
	module Helper
		module Shell
			class << self
				def execute(cmd)
					unless system(cmd)
						$logger.error "Error executing command '#{cmd}'"
						raise "Error executing command '#{cmd}'"
					end
				end
			end
		end
	end
end
