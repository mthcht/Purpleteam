
This script allows you to execute Python or Bash scripts/commands through the Tor network using a Docker container. It creates a new Docker container, installs Tor, executes your script within the container, returns the result, and then deletes the container.

### Prerequisites
- Python 3
- Docker


### Execute a Python script:
python3 Execute_with_TOR_docker.py --python your_script.py

### Execute a Bash script:
python3 Execute_with_TOR_docker.py --bash your_script.sh

### Execute a curl command through Tor:
python3 Execute_with_TOR_docker.py --bash "curl 'https://api.ipify.org?format=json'"

In this example, the result of the command should be the IP address of the TOR exit node used.

![image](https://github.com/mthcht/Purpleteam/assets/75267080/318a4d2b-b537-43b0-90ed-607f39ad2874)
