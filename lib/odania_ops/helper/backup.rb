module OdaniaOps
	module Helper
		class Backup
			def space_used(user, host)
				result = `echo "df -h" | sftp -b - #{user}@#{host}`
				puts result.inspect
			end
		end
	end
end
