set today to ((current date) as string)

try
	set ping_result to (do shell script "ping -c 1 SHODAN.local")
	
	if ping_result contains "bytes from" then
		
		tell application "System Events" to set my_disks to name of every disk
		
		if "WORK" is in my_disks then
			
			return today & " - SHODAN is already mounted"
			
		else
			
			try
				mount volume "WORK" on server "shodan"
			on error errmsg
			end try
			
			try
				mount volume "BACKUP" on server "shodan"
			on error errmsg
			end try
		
			try
				mount volume "XFR" on server "shodan"
			on error errmsg
			end try
			
			try
				mount volume "REPOSITORY" on server "shodan"
			on error errmsg
			end try
			
			return today & " - SHODAN found and mounted"
			
		end if
		
	else
		
		return today & " - SHODAN not online"
		
	end if
	
on error errmsg
	return today & " - network error: " & errmsg
end try
