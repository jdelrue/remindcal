#!/bin/bash
export DISPLAY=:0
is_earlier() {
    time1="$1"
    time2="$2"

    # Extract hours and minutes from the time strings
    hour1=${time1%%:*}
    minute1=${time1#*:}
    hour2=${time2%%:*}
    minute2=${time2#*:}

    # Convert the times to minutes since midnight
    minutes1=$((hour1 * 60 + minute1))
    minutes2=$((hour2 * 60 + minute2))

    # Compare the two times and return the result
    if [ "$minutes1" -lt "$minutes2" ]; then
        return 0  # Time1 is earlier than Time2
    else
        return 1  # Time1 is not earlier than Time2
    fi
}

# Set the time window for upcoming meetings (in minutes)
TIME_WINDOW=10
CURRENT_HOUR_MINUTES=$(date +%H:%M)

CURRENT_TIME=$(date -Is)

# Calculate the end time of the time window (in ISO 8601 format)
END_TIME=$(date -Is -d "+$TIME_WINDOW minutes")

# Use gcalcli to fetch upcoming events within the time window
# Replace 'your_google_calendar_name' with your actual calendar name
ALL_MEETINGS=$(gcalcli --nocolor agenda "$CURRENT_TIME" "$END_TIME" --calendar 'jonas.delrue@jimber.org'  )


UPCOMING_MEETINGS=""

# Loop through each line of the output and filter out only upcoming meetings
while IFS= read -r line; do
  # Extract the hour and minutes from the line
  start_hour_minutes=$(echo "$line" | awk '{print $4}')
  # Compare the event start time with the current time
  if is_earlier "$start_hour_minutes" "$CURRENT_HOUR_MINUTES"; then
    # Add the line to the list of upcoming meetings
    echo ongoing meeting
  else
    UPCOMING_MEETINGS="$UPCOMING_MEETINGS<br>$line"
  fi
done <<< "$ALL_MEETINGS"


# Remove leading newline character
UPCOMING_MEETINGS="${UPCOMING_MEETINGS#'<br>'}"

echo $UPCOMING_MEETINGS


# Check if there are any meetings (non-empty output)
if [[ -z "$UPCOMING_MEETINGS" ]]; then
	echo "No upcoming meetings."
    exit 0
else
    # Replace the following line with your desired command to execute
    echo "You have upcoming meetings:"
    echo "$UPCOMING_MEETINGS"
    MEETINGS=$("$UPCOMING_MEETINGS")
    echo $MEETINGS
    google-chrome --user-data-dir=/home/jdelrue/RemindCal/profile/ --kiosk --fullscreen "file:///home/jdelrue/RemindCal/static/index.html?meeting=$UPCOMING_MEETINGS" --incognito --disable-pinch --no-user-gesture-required --overscroll-history-navigation=0 &
    
fi
export XDG_RUNTIME_DIR="/run/user/1001/"
cd /home/jdelrue/RemindCal/
cat static/ding.mp3 | ffplay -v 0 -nodisp -autoexit -
sleep 0.5
cat static/ding.mp3 | ffplay -v 0 -nodisp -autoexit -
sleep 0.5
cat static/ding.mp3 | ffplay -v 0 -nodisp -autoexit -