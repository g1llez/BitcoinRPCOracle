#!/bin/bash

# Cache directory
CACHE_DIR="/var/cache/utxoracle"
CACHE_FILE="$CACHE_DIR/last_price.txt"

# Path to main script
UTXORACLE_SCRIPT="$(dirname "$0")/UTXOracle.py"
SCRIPT_DIR="$(dirname "$0")"

# Create cache directory if needed
mkdir -p "$CACHE_DIR"

# Execute Python script
cd "$(dirname "$UTXORACLE_SCRIPT")"
OUTPUT=$(python3 "$UTXORACLE_SCRIPT" -rb --no-html 2>&1)

# Extract the line containing the price (e.g., "Jul 14, 2025 price: $100,361"), ignore leading spaces
PRICE_LINE=$(echo "$OUTPUT" | grep "price:")
PRICE=$(echo "$PRICE_LINE" | grep -oE '\\$[0-9,]+' | head -1 | sed 's/\\$//;s/,//g')

# Extract date in international format (YYYY-MM-DD)
# We assume the English date is of type "Jul 14, 2025"
DATE_EN=$(echo "$PRICE_LINE" | grep -oE '^[A-Z][a-z]{2} [0-9]{1,2}, [0-9]{4}')
DATE_ISO=$(date -d "$DATE_EN" +"%Y-%m-%d" 2>/dev/null)

# Extract price as integer (e.g., 99999)
PRICE_RAW=$(echo "$PRICE_LINE" | grep -oE '\$[0-9,]+')
PRICE=$(echo "$PRICE_RAW" | sed 's/\$//;s/,//g')

# If date is not found, fallback to current date
if [ -z "$DATE_ISO" ]; then
  DATE_ISO=$(date -u +"%Y-%m-%d")
fi

# Save to cache file
{
  echo "date: $DATE_ISO"
  echo "price: $PRICE"
  echo "timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
} > "$CACHE_FILE" 