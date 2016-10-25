-- AppleScipt script to scrap a GIThub project, currently open in FireFox,
-- into one single PDF note in DEVINthink.
-- (cc0) 
-- 2016/@imifos

global downloadedurls
global allnewnotes

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

say "Operation completed."

return


-- ------------------------------------------
--
on merge_all_pages(newwebsiteurl)
	
	if allnewnotes is {} then
		say "No pages to scraped!"
		return
	end if
	
	tell application id "com.devon-technologies.thinkpro2"
		
		-- Merge newly created notes into one and get rid of the single ones
		set mergedpage to merge records allnewnotes
		set the name of mergedpage to newwebsiteurl
		repeat with itemtodelete in allnewnotes
			delete record itemtodelete
		end repeat
		
	end tell
	
end merge_all_pages


-- ------------------------------------------
--
-- Downloads a page, creates a note in DT, scans for sub-URLs and recursively handles the sub-URLs 
--
on handle_page(newwebsiteurl)
	
	-- Avoid following links to myself
	log "Handle URL " & newwebsiteurl
	if downloadedurls contains newwebsiteurl then
		return
	end if
	set downloadedurls to downloadedurls & newwebsiteurl
	
	
	-- Skip various cases
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
	
	
	-- Fetch the current page
	tell application id "com.devon-technologies.thinkpro2"
		
		-- Create PDF image in DEVONthink
		set contentobject to create PDF document from newwebsiteurl name newwebsiteurl
		
		-- Add new DEVONthink object to the "to be merged" list
		set end of allnewnotes to contentobject
		
		-- Ask DEVONthink to download the page source (no need to call a browser for this)
		set websitesource to download markup from newwebsiteurl
		
		-- Get URLs of all sub-pages
		set subpageurls to get links of websitesource base URL newwebsiteurl
		
	end tell
	
	-- Recursively handle sub pages one by one
	repeat with subpageurl in subpageurls
		if subpageurl contains "/blob/master/" or subpageurl contains "/tree/master/" then
			if subpageurl does not contain "#" then
				handle_page(subpageurl)
			end if
		end if
	end repeat
	
end handle_page
