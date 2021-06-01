#!/bin/bash

username=$1
image_name=$2
url_auth="http://localhost:8000/auth"
url_image="http://localhost:8000/image"
access_token=""
json_response=""
login_failed_message="Incorrect username or password"

if [ -z "$username" ] || [ -z "$image_name" ]; then
  echo "WARNING: Please provide username and image name"
  exit 1
else
  echo "====> Login START"
  json_response=$(curl -X POST -F "username=$username" -F 'password=secret' "$url_auth")
fi

if [ $? -eq 7 ]; then
  echo "WARNING: Please start the docker-container"
  exit 1
fi

if [ "$(echo "${json_response}" | jq -r '.detail')" == "$login_failed_message" ]; then
  echo "WARNING: Login FAILED. $login_failed_message"
  exit 1
fi
echo "====> Login END"

echo "====> Start to get an access token"
if [ -z "$json_response" ]; then
  echo "WARNING: Response is empty"
  exit 1
else
  access_token=$(echo "${json_response}" | jq -r '.access_token')
fi
echo "====> Access token received successfully"

echo "====> Download and save $image_name.png image to the file"
if [ -z "$access_token" ]; then
  echo "WARNING: Access token is empty"
  exit 1
else
  curl -H "Authorization: Bearer $access_token" "$url_image" -o "$image_name.png"
fi
echo "====> Image saved successfully"
