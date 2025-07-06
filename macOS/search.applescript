#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Search
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌐
# @raycast.argument1 { "type": "text", "placeholder": "Search Query" }
# @raycast.packageName Web

# Documentation:
# @raycast.description Search with Safari's default search engine.
# @raycast.author Justin
# @raycast.authorURL https://github.com/jkimble

on run argv
    set query to item 1 of argv

    tell application "Safari"
        activate
        search the web for query
       end tell
end run

