#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Web Search
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌐
# @raycast.argument1 { "type": "text", "placeholder": "Search Query" }
# @raycast.packageName Productivity

# Documentation:
# @raycast.description Web search with default Safari search engine.
# @raycast.author Justin

on run argv
    set query to (item 1 of argv)

    tell application "Safari"
        activate
        search the web for query
    end tell
end run
