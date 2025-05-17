#!/bin/bash
set -e

website="$WEBFLOW_WEBSITE"

echo "Starting site fetch for $website..."

response=$(curl -s -H "Content-Type: application/json" "{\"url\":\"$website\"}" https://09nc56i46a.execute-api.eu-north-1.amazonaws.com/export | tr -d '\n\r')

# Remove everything before the first "s3Link":"
tmp=${response#*\"s3Link\": \"}

# Remove everything after the closing quote of the URL
s3_link=${tmp%%\"*}

echo "s3_link: $s3_link"

if [ -z "$s3_link" ] || [ "$s3_link" = "null" ]; then
  echo "Failed to get s3Link from API response"
  exit 1
fi

echo "Downloading ZIP from: $s3_link"

curl -s -o website.zip "$s3_link"

echo "Unzipping downloaded file..."

# Clean target directory first (you may change 'public' if your build dir differs)
rm -rf public
mkdir public

unzip -q website.zip -d tmp_unzip_dir

# Move first-level content inside tmp_unzip_dir to public/
first_dir=$(find tmp_unzip_dir -mindepth 1 -maxdepth 1 -type d | head -n 1)

if [ -z "$first_dir" ]; then
  echo "No directory found in ZIP"
  exit 1
fi

mv "$first_dir"/* public/

# Clean up
rm -rf tmp_unzip_dir website.zip

echo "Website code downloaded and extracted to 'public/'"
