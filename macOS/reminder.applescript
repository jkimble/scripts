#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Reminder
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📝
# @raycast.argument1 { "type": "text", "placeholder": "Reminder" }
# @raycast.argument2 { "type": "text", "placeholder": "Hours from now", "optional": true }
# @raycast.argument3 { "type": "text", "placeholder": "Days from now", "optional": true }
# @raycast.packageName Shortcuts

# Documentation:
# @raycast.description Quickly create a reminder with a command.
# @raycast.author Justin
# @raycast.authorURL https://github.com/jkimble

on run argv
    set title to item 1 of argv
    if (count of argv) ≥ 2 then
        set hours to (item 2 of argv) as integer
    else
        set hours to 0
    end if
    if (count of argv) ≥ 3 then
        set days to (item 3 of argv) as integer
    else
        set days to 0
    end if
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