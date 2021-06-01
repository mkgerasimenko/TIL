## How to create a shell script with conditions, args, and variables.

The initial task for today's scripting is working with the `shell`. 
*The `shell` is a program that takes commands from the keyboard and gives them to the operating system to perform.*

A `shell script` is a list of commands in a computer program that is run by the Unix shell which is a command-line interpreter. 

**The task is:** 
1. Install `Docker`.
2. Pull `sskorol/http-playground` container locally.
3. Run a downloaded container in the background. 
Map `8000` container's port to your host's `8000` port so that a newly started http server will be available from within your local network on `localhost:8000`.

Create a shell script which does the following:
1. Sends a `POST` request via `curl` to `/auth` endpoint of your recently started server. 
You have to pass the following form data: `username = GitHub id`, `password = secret`.
2. Extracts `access_token` from the response body into a `variable`.
3. Sends a `GET` request to `/image` endpoint with the `authorization header of Bearer` type and the `access_token` value.
4. Saves the response output to a file. Note that it's a `.png` image.

### Docker installing

Docker Desktop is available for Mac and Windows:
 - [Install Docker Desktop on Mac](https://docs.docker.com/docker-for-mac/install/)
 - [Install Docker Desktop on Windows](https://docs.docker.com/docker-for-windows/install/)
 
Also, we can install docker on any Linux platforms:
 - [Install Docker on Linux](https://docs.docker.com/engine/install/#server)
 
#### Installing Docker on Mac With Homebrew Cask

If you have `Homebrew` installed, you can execute the following command to install Docker:

```bash
brew cask install docker
```

### Pull an image or a repository from the Docker Hub

To download a particular image, or set of images (i.e., a repository), use `docker pull`. For our task we should use next: 

```bash
docker pull sskorol/http-playground
```

Check out more about [docker pull here](https://docs.docker.com/engine/reference/commandline/pull/)

### Run image as a docker-container

Start the container and expose port `8000` to port `8000` on the host:

```bash
docker run --publish 8000:8000 sskorol/http-playground
```

**BUT**, we should run container in **detached** mode. To do this, we can use the `--detach` or `-d` for short. 
Docker will start your container the same as before but this time will “detach” from the container and return you to the terminal prompt:

```bash
docker run -d -p 8000:8000 sskorol/http-playground
```

### Install the subsidiary program for response initialization ([jq](https://stedolan.github.io/jq/manual/))

A `jq` program is a **"filter"**: it takes an input, and produces an output. 
There are a lot of builtin filters for extracting a particular field of an object, or converting a number to a string, or various other standard tasks.\
`jq` is for **JSON** data - you can use it to **slice** and **filter** and **map** and **transform** structured data.

For example, to get the `detail` value from `{"detail":"Incorrect username or password"}` response we should use next command with saving to the variable: 

```bash
detail_value=$(echo '{"detail":"Incorrect username or password"}'| jq -r '.detail')
echo "$detail_value"
```

### Create shell script

Before the start of creation the script we should `identify variables` for easier programming.

 - **username** -> First argument and a variable for the script
 - **image_name** -> Second argument and variable for the script
 - **url_auth** -> Authorization url path 
 - **url_image** -> Image url path
 - **access_token** -> Access token
 - **json_response** -> Response from `POST` request
 - **login_failed_message** -> Error message during login
 
#### Send `POST` request to the `/auth` path

```bash
curl -X POST -F 'username=mkgerasimenko' -F 'password=secret' http://localhost:8000/auth
```

####
**During this execution, we can get the following errors:**
 - The username isn't provided
 - The image name isn't provided
 - curl: (7) Failed to connect to localhost port `8000`: Connection refused (Docker isn't started)
 - Incorrect username or password
 - Response and Access token are empty
 
**Username and image name verification:**

```bash
if [ -z "$username" ] || [ -z "$image_name" ]; then
  echo "WARNING: Please provide username and image name"
  exit 1
else
  json_response=$(curl -X POST -F "username=$username" -F 'password=secret' "$url_auth")
fi
```

**Docker verification:**

```bash
if [ $? -eq 7 ]; then
  echo "WARNING: Please start the docker-container"
  exit 1
fi
```

**Login verification:**

```bash
if [ "$(echo "${json_response}" | jq -r '.detail')" == "$login_failed_message" ]; then
  echo "WARNING: Login FAILED. $login_failed_message"
  exit 1
fi
```

**Response and Access token verification:**

```bash
if [ -z "$json_response" ]; then
  echo "WARNING: Response is empty"
  exit 1
fi
```

```bash
if [ -z "$access_token" ]; then
  echo "WARNING: Access token is empty"
  exit 1
fi
```

### Send `GET` request to the `/image` and save response image to a `.file`

```bash
curl -H "Authorization: Bearer $access_token" "$url_image" -o "$image_name.png"
```

The image will download to the directory in which the script was executed.

### The final outcome

```bash
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
```

Also, the `github_id_img.sh` is available [here](https://github.com/mkgerasimenko/TIL/blob/main/shell/github_id_img.sh)

### Run the script

Before running the shell-script we should get permissions to it:

```bash
chmod 755 github_id_img.sh
```

Run the script with two args:

```bash
./github_id_img.sh username image_name
```

#### For more information about this topic, please use the links below: 

[Shell scripting](https://www.tutorialkart.com/bash-shell-scripting/bash-date-format-options-examples/) \
[Docker overview](https://docs.docker.com/get-started/overview/) \
[The Art Of Scripting HTTP Requests Using Curl](https://curl.se/docs/httpscripting.html)
