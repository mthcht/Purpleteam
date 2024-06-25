
This script allows you to execute Python or Bash scripts/commands through the Tor network using a Docker container

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
![Uploading image.png…]()
