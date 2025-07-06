#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title New Note
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🗒️
# @raycast.argument1 { "type": "text", "placeholder": "Title" }
# @raycast.argument2 { "type": "text", "placeholder": "Content" }
# @raycast.packageName Notes

# Documentation:
# @raycast.description Creates a new note.
# @raycast.author Justin

on run argv
	set content to "<body><h1 style=\"color:black;\"> " & (item 1 of argv) & "</h1>
	<p style=\"color:black;\" >" & (item 2 of argv) & "</p>
	</body>"

	tell application "Notes"
		activate
		make new note at folder "Notes" with properties {name:"", body:content}
		log "New note created!"
	end tell
end run

