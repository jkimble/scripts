# macOS scripts
___
These scripts are made to interact with Mac/iOS apps/systems.

**_Raycast is highly recommended to run these scripts._** 
It provides a nice UI and displays parameters.

### Example
To run these scripts from the command line:
```
osascript macOS/clear-downloads.applescript
```

## Documentation
___
### Clear Downloads
No parameters. Will prompt to make sure you want to clear downloads if
there are 10 or more files.
```
osascript macOS/clear-downloads.applescript
```

### Note
Creates a new note in the Notes app.
```
osascript macOS/note.applescript "TITLE" "CONTENT"
```
**TITLE** — Note title.

**CONTENT** — Body content of the note.

### Reminder
Creates a new reminder in the Reminder app.
```
osascript macOS/reminder.applescript "REMINDER" "MINUTES" "HOURS"
```
**REMINDER** — Text of the reminder.

**MINUTES** — (Optional) Minutes from now when the reminder should trigger.

**HOURS** — (Optional) Hours from now when the reminder should trigger.

### Search
Searches the web using Safari's default search engine.
```
osascript macOS/search.applescript "SEARCH QUERY"
```
**SEARCH_QUERY** — The text to search for.
