#!/bin/bash

LOG_DIR="../logs"
ERROR_PATTERNS=("ERROR" "FATAL" "CRITICAL")
REPORT_FILE="log_analysis_report.txt"
THRESHOLD=10

echo "analysing log files" > "$REPORT_FILE"
echo "==============================" >> "$REPORT_FILE"

echo -e "\nList of log files updated in last 24 hours" >> "$REPORT_FILE"

# Safely handle spaces in file names using mapfile and find
mapfile -t LOG_FILES < <(find "$LOG_DIR" -name "*.log" -mtime -30)

# Print the list of files to the report
for FILE in "${LOG_FILES[@]}"; do
    echo "$FILE" >> "$REPORT_FILE"
done

for LOG_FILE in "${LOG_FILES[@]}"; do
    echo -e "\n" >> "$REPORT_FILE"
    echo "==================================================" >> "$REPORT_FILE"
    echo "==================== $LOG_FILE ====================" >> "$REPORT_FILE"
    echo "==================================================" >> "$REPORT_FILE"

    for PATTERN in "${ERROR_PATTERNS[@]}"; do
        echo -e "\nsearching $PATTERN logs in $LOG_FILE file" >> "$REPORT_FILE"
        # Added a space between pattern and file, and used variables properly
        grep "$PATTERN" "$LOG_FILE" >> "$REPORT_FILE"

        echo -e "\nNumber of $PATTERN logs found in $LOG_FILE" >> "$REPORT_FILE"
        
        # Correct syntax for saving command output to a variable: $(command)
        ERROR_COUNT=$(grep -c "$PATTERN" "$LOG_FILE")
        echo "$ERROR_COUNT" >> "$REPORT_FILE"

        # Fixed syntax: Spaces inside brackets are mandatory, and variables need '$'
        if [ "$ERROR_COUNT" -ge "$THRESHOLD" ]; then
            echo "ACTION REQUIRED: $LOG_FILE has $ERROR_COUNT $PATTERN lines"
        fi
    done
done

echo "Report saved: $REPORT_FILE"
