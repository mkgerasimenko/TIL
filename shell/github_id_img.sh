#!/bin/bash
username=$1
image_name=$2
url_auth=http://localhost:8000/auth
url_image=http://localhost:8000/image
access_token=""
json_response=""
login_failed_message="Incorrect username or password"

[[ -z "$username" || -z "$image_name" ]] && { echo "WARNING: Please provide username and image name"; exit 1; } \
										 || { echo "====> Login START"; json_response=$(curl -X POST -F 'username='"$username" -F 'password=secret' "$url_auth"); }

[[ $? -eq 7 ]] && { echo "WARNING: Please start the docker-container"; exit 1; }

[[ $(echo "${json_response}" | jq -r '.detail') = "$login_failed_message" ]] && { echo "WARNING: Login FAILED. $login_failed_message"; exit 1; }
echo "====> Login END"

echo "====> Start to get an access token"
[ -z "$json_response" ] && { echo "WARNING: Response is empty"; exit 1; } \
						|| access_token=$(echo "${json_response}" | jq -r '.access_token')
echo "====> Access token received successfully"

echo "====> Download and save "$image_name.png" image to the file"
[ -z "$access_token" ] && { echo "WARNING: Access token is empty"; exit 1; } \
 					   ||curl -H "Authorization: Bearer $access_token" "$url_image" >> "$image_name.png"
echo "====> Image saved successfully"
