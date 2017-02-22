-- AppleScipt to scrap a GIThub project, currently open in FireFox,
-- into one single PDF note in DEVINthink.
-- Install this script here: /Users/<youaccount>/Library/Scripts/Applications/Firefox
-- (cc0) 
-- 2016-2017/@imifos
-- v2

global downloadedurls
global allnewnotes
global basewebsiteurl

set allnewnotes to {}
set downloadedurls to {}

-- Get current URL from Firefox
tell application "Firefox" to activate
tell application "System Events"
	keystroke "l" using command down
	keystroke "c" using command down
end tell
delay 0.5
set basewebsiteurl to the clipboard

say "Scraping started!"
log "Started with URL " & basewebsiteurl

-- Block non GIThub.com URLs
if basewebsiteurl does not contain "/github.com/" then
	say "Current page is not a github repository. Stop here."
	return
end if

try
	-- Recursively fetch the repository into notes
	my handle_page(basewebsiteurl)
	
	-- Merge the above notes into one single note
	my merge_all_pages(basewebsiteurl)
	
on error error_message number error_number
	say "There is an error, please check dialog window!"
	display alert "Scrap Github repository into DEVONthink" message error_message as warning
end try

log "Operation completed"
say "Operation completed."

return


-- ------------------------------------------
--
on merge_all_pages(newwebsiteurl)
	
	log "Merge single pages into one document"
	
	if (count of allnewnotes) > 0 then
		tell application id "DNtp"
			
			-- Merge newly created notes into one and get rid of the single ones
			set mergedpage to merge records allnewnotes
			set the name of mergedpage to newwebsiteurl
			repeat with itemtodelete in allnewnotes
				delete record itemtodelete
			end repeat
			
		end tell
	else
		say "No pages to scraped!"
	end if
	
end merge_all_pages


-- ------------------------------------------
--
-- Downloads a page, creates a note in DT, scans for sub-URLs and recursively handles the sub-URLs 
--
on handle_page(newwebsiteurl)
	
	-- Skip various cases
	
	if newwebsiteurl does not contain "/blob/master/" and newwebsiteurl does not contain "/tree/master/" and newwebsiteurl is not basewebsiteurl then
		-- log "Skipped URL as not a master branch file " & newwebsiteurl
		return
	end if
	
	if not {newwebsiteurl begins with basewebsiteurl} then
		log "Skipped URL as reference to other repository " & newwebsiteurl
		return
	end if
	
	if newwebsiteurl contains "#" then
		log "Skipped URL as it's a relative jump " & newwebsiteurl
		return
	end if
	
	if not {newwebsiteurl begins with "http:" or newwebsiteurl begins with "https:"} then
		log "Page URL does not start with http! " & newwebsiteurl
		return
	end if
	
	if newwebsiteurl contains "README.md" then
		-- No need to scrap the README as it's displayed as part of the parent page
		log "Skipped README.md at " & newwebsiteurl
		return
	end if
	
	if newwebsiteurl contains "?raw=true" then
		-- Do not scrap binary files as they do not well in PDF format :)
		log "Skipped binary file at " & newwebsiteurl
		return
	end if
	
	if downloadedurls contains newwebsiteurl then
		log "URL already downloaded, so it's not done again " & newwebsiteurl
		return
	end if
	
	set downloadedurls to downloadedurls & newwebsiteurl
	
	-- Fetch the current page
	tell application id "DNtp"
		
		log "Tell DT to scrap " & newwebsiteurl
		
		-- Create PDF image in DEVONthink
		repeat with i from 1 to 5
			log "   Download tenative " & i
			set contentobject to create PDF document from newwebsiteurl name newwebsiteurl
			log "   DT is back!"
			if contentobject is not missing value then exit repeat
		end repeat
		
		if contentobject is missing value then
			log "  DT create PDF document returns 'missing value'"
			log "      from: " & newwebsiteurl & ", name: " & newwebsiteurl
			log "      return: " & contentobject
			say "Warning! A page could not been downloaded!"
		end if
		
		-- Add new DEVONthink object to the "to be merged" list
		set end of allnewnotes to contentobject
		
		-- Ask DEVONthink to download the page source (no need to call a browser for this)
		set websitesource to download markup from newwebsiteurl
		
		-- Get URLs of all sub-pages
		set subpageurls to get links of websitesource base URL newwebsiteurl
		
	end tell
	
	-- Recursively handle sub pages one by one
	repeat with subpageurl in subpageurls
		handle_page(subpageurl)
	end repeat
	
end handle_page
