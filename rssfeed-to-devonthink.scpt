-- AppleScipt that creates a RSS feed type note in DEVINthink, taking the currently 
-- open URL from FireFox.
-- Install this script here: /Users/<youaccount>/Library/Scripts/Applications/Firefox
-- (cc0) - Free for all 
-- Mstly founbd on the internet, especially the DT forum.
-- 2016/@imifos
-- v1

-- Adapt to your target database:
set targetDatabaseName to "⭕News Feeds"

--
-- Get current URL from Firefox
tell application "Firefox" to activate
tell application "System Events"
	keystroke "l" using command down
	keystroke "c" using command down
end tell
delay 0.5
set basewebsiteurl to the clipboard

-- Create RSS type node in DEVONthink 
tell application id "DNtp"
	
	set websitesource to download markup from basewebsiteurl
	set sitetitle to get title of websitesource
	
	set targetgroup to display group selector "Choose target group for new feed..." for database targetDatabaseName
	
	create record with {name:sitetitle, type:feed, URL:basewebsiteurl} in targetgroup
	
end tell
