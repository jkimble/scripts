#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Email
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ✉️
# @raycast.argument1 { "type": "text", "placeholder": "To", "optional": true, "percentEncoded": true }
# @raycast.argument2 { "type": "text", "placeholder": "Subject", "optional": true, "percentEncoded": true }
# @raycast.argument3 { "type": "text", "placeholder": "Body", "optional": true, "percentEncoded": true }
# @raycast.packageName Mail

# Documentation:
# @raycast.description Create a new email to a recipient.
# @raycast.author Justin
# @raycast.authorURL https://github.com/jkimble

open "mailto:${1}?subject=${2}&body=${3}"