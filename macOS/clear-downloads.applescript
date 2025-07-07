#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Clear Downloads
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🗑️
# @raycast.packageName Utilities

# Documentation:
# @raycast.description Clears the downloads directory.
# @raycast.author Justin
# @raycast.authorURL https://github.com/jkimble

set downloadsDir to (path to downloads folder) as text

tell application "Finder"
  set folderSize to count of items of folder downloadsDir
end tell

if folderSize = 0 then
  return "Already empty!"
else if folderSize > 9 then
  display dialog "There are " & folderSize & " items in your Downloads folder. Do you want to delete them all?" buttons {"Cancel", "Delete"} default button "Cancel" cancel button "Cancel"
  if button returned of result is "Delete" then
    tell application "Finder" to delete every item of folder downloadsDir
    return "Downloads cleared!"
  else
    return "Deletion cancelled."
  end if
else
  tell application "Finder" to delete every item of folder downloadsDir
  return "Downloads cleared!"
end if
