#!/bin/bash

remove_color_codes() {
  local text="$1"

  # Use sed to remove color codes (without -r)
  text=$(echo "$text" | sed 's/\x1B\[[0-9;]*[mK]//g')

  echo "$text"
}



# Set the time window for upcoming meetings (in minutes)
TIME_WINDOW=10

# Get the current time in ISO 8601 format
CURRENT_TIME=$(date -Is)

# Calculate the end time of the time window (in ISO 8601 format)
END_TIME=$(date -Is -d "+$TIME_WINDOW minutes 5 seconds")

# Use gcalcli to fetch upcoming events within the time window
# Replace 'your_google_calendar_name' with your actual calendar name
MEETINGS=$(gcalcli agenda "$CURRENT_TIME" "$END_TIME" --calendar 'jonas.delrue@jimber.org')
# Check if there are any meetings (non-empty output)
if [[ $MEETINGS == *"No Events Found"* ]]; then
	echo "No upcoming meetings."
else
    # Replace the following line with your desired command to execute
    echo "You have upcoming meetings:"
    echo "$MEETINGS"
    MEETINGS=$(remove_color_codes "$MEETINGS")
    echo $MEETINGS
    google-chrome --user-data-dir=/home/jdelrue/RemindCal/profile/ --kiosk --fullscreen "file:///home/jdelrue/RemindCal/static/index.html?meeting=$MEETINGS" --incognito --disable-pinch --no-user-gesture-required --overscroll-history-navigation=0
    
fi
