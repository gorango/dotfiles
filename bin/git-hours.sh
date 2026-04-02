#!/bin/bash

# Timezone-Aware Git Hours Calculator
# Shows times in the original commit timezone
# Usage: ./git_hours.sh [author_name] [since_date]

AUTHOR=${1:-$(git config user.name)}
SINCE=${2:-"1 month ago"}

echo "=== Timezone-Aware Hours Calculator ==="
echo "Author: $AUTHOR"
echo "Since: $SINCE"
echo "Work day: 6:00 AM - 3:59 AM (next day) in commit timezone"
echo "======================================================="
echo

# Get commits with both UTC timestamp and timezone info
git log --author="$AUTHOR" --since="$SINCE" --pretty=format:"%at %ai" | awk '
BEGIN {
    total_hours = 0
    total_days = 0
    print "Processing commits with timezone awareness..."
}

{
    utc_timestamp = $1
    # Parse the timezone-aware date (format: 2024-01-15 14:30:25 -0800)
    commit_date = $2
    commit_time = $3
    commit_tz = $4

    # Extract hour from commit time
    split(commit_time, time_parts, ":")
    hour = time_parts[1]

    # Determine work day based on commit timezone
    work_day = commit_date
    if (hour < 4) {
        cmd = "date -d \"" commit_date " - 1 day\" +\"%Y-%m-%d\""
        cmd | getline work_day
        close(cmd)
    }

    # Store timestamps and timezone info for each work day
    if (work_day in first_commit_utc) {
        if (utc_timestamp < first_commit_utc[work_day]) {
            first_commit_utc[work_day] = utc_timestamp
            first_commit_local[work_day] = commit_date " " commit_time " " commit_tz
        }
        if (utc_timestamp > last_commit_utc[work_day]) {
            last_commit_utc[work_day] = utc_timestamp
            last_commit_local[work_day] = commit_date " " commit_time " " commit_tz
        }
    } else {
        first_commit_utc[work_day] = utc_timestamp
        last_commit_utc[work_day] = utc_timestamp
        first_commit_local[work_day] = commit_date " " commit_time " " commit_tz
        last_commit_local[work_day] = commit_date " " commit_time " " commit_tz
    }

    # Store timezone for this work day
    work_day_tz[work_day] = commit_tz
}

END {
    print ""
    print "Work Day   | First Commit | Last Commit  | Duration | +2hrs | Total     | TZ"
    print "-----------|--------------|--------------|----------|-------|-----------|-----"

    for (day in first_commit_utc) {
        # Calculate duration using UTC timestamps (accurate)
        duration = last_commit_utc[day] - first_commit_utc[day]
        total_seconds = duration + 7200  # Add 2 hours
        hours = total_seconds / 3600

        # Extract display times from local timezone strings
        split(first_commit_local[day], first_parts, " ")
        split(last_commit_local[day], last_parts, " ")

        first_time = substr(first_parts[2], 1, 5)  # HH:MM
        last_time = substr(last_parts[2], 1, 5)    # HH:MM

        # Check if commits were after midnight (based on original timezone)
        first_hour = substr(first_parts[2], 1, 2)
        last_hour = substr(last_parts[2], 1, 2)

        first_indicator = (first_hour < 6) ? "+" : ""
        last_indicator = (last_hour < 6) ? "+" : ""

        # Format duration
        duration_hours = int(duration / 3600)
        duration_minutes = int((duration % 3600) / 60)
        duration_str = sprintf("%d:%02d", duration_hours, duration_minutes)

        # Format total
        total_hours_int = int(total_seconds / 3600)
        total_minutes = int((total_seconds % 3600) / 60)
        total_str = sprintf("%d:%02d", total_hours_int, total_minutes)

        tz = work_day_tz[day]

        printf "%s | %7s%s | %7s%s | %8s | +2:00 | %s (%.1fh) | %s\n",
               day, first_time, first_indicator, last_time, last_indicator,
               duration_str, total_str, hours, tz

        total_hours += hours
        total_days++
    }

    print "-----------|--------------|--------------|----------|-------|-----------|-----"
    print ""
    print "📊 SUMMARY"
    print "----------"
    print "Total work days:", total_days
    printf "Total hours: %.1f\n", total_hours
    if (total_days > 0) {
        printf "Average hours per day: %.1f\n", total_hours / total_days
    }
    print ""
    print "Note: Times shown in original commit timezone"
}'
