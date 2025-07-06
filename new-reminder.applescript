#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title New Reminder
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📝
# @raycast.argument1 { "type": "text", "placeholder": "Reminder" }
# @raycast.argument2 { "type": "text", "placeholder": "Hours from now", "optional": true }
# @raycast.argument3 { "type": "text", "placeholder": "Days from now", "optional": true }
# @raycast.packageName Productivity

# Documentation:
# @raycast.description Create a new Reminder.
# @raycast.author Justin

on run argv
    set title to item 1 of argv
    set hours to item 2 of argv as integer
    set days to item 3 of argv as integer
    set secondsPerDay to 24 * 60 * 60
    set secondsPerHour to 60 * 60

    set remindDate to (current date) + (days * secondsPerDay) + (hours * secondsPerHour)

    tell application "Reminders"
        tell list "Reminders"
            make new reminder with properties {name:title, remind me date:remindDate}
            log "New reminder created!"
        end tell
    end tell
end run