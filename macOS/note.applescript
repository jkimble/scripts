#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Note
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🗒️
# @raycast.argument1 { "type": "text", "placeholder": "Title" }
# @raycast.argument2 { "type": "text", "placeholder": "Content" }
# @raycast.packageName Shortcuts

# Documentation:
# @raycast.description Create a new note with a command.
# @raycast.author Justin
# @raycast.authorURL https://github.com/jkimble

on run argv
    set title to item 1 of argv
    set body to item 2 of argv
	set content to "<body><h1> " & title & "</h1><p>" & body & "</p></body>"

	tell application "Notes"
		activate
		make new note at folder "Notes" with properties {name:"", body:content}
		return "New note created!"
	end tell
end run
