import os
import sys
import subprocess
import tempfile
import shutil
import argparse

DOCKERFILE_CONTENT = """
FROM debian:latest

RUN apt-get update && \\
    apt-get install -y tor python3 python3-pip curl netcat-openbsd

# Tor configuration
RUN mkdir -p /var/lib/tor
RUN chown -R debian-tor:debian-tor /var/lib/tor

COPY start_tor.sh /usr/local/bin/start_tor.sh
RUN chmod +x /usr/local/bin/start_tor.sh

ENTRYPOINT ["/usr/local/bin/start_tor.sh"]
"""

START_TOR_SCRIPT_CONTENT = """#!/bin/bash
tor &

# Wait for Tor to start
sleep 10

# Check if Tor SOCKS proxy is available
while ! nc -z localhost 9050; do
    sleep 1
done

# Export the Tor proxy environment variables
export http_proxy="socks5h://127.0.0.1:9050"
export https_proxy="socks5h://127.0.0.1:9050"

# Execute the command passed as arguments
exec "$@"
"""

def create_dockerfile(temp_dir):
    dockerfile_path = os.path.join(temp_dir, "Dockerfile")
    with open(dockerfile_path, "w") as f:
        f.write(DOCKERFILE_CONTENT)
    return dockerfile_path

def create_start_tor_script(temp_dir):
    script_path = os.path.join(temp_dir, "start_tor.sh")
    with open(script_path, "w", newline='\n') as f:
        f.write(START_TOR_SCRIPT_CONTENT)
    os.chmod(script_path, 0o755)
    return script_path

def build_docker_image(temp_dir):
    subprocess.check_call(["docker", "build", "-t", "tor_temp_env", temp_dir])

def execute_in_docker(command, interpreter):
    docker_command = [
        "docker", "run", "--rm", "tor_temp_env", interpreter, "-c", command
    ]
    result = subprocess.run(docker_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return result.stdout.decode(), result.stderr.decode()

def copy_script_to_temp_dir(script_path, temp_dir):
    script_dest_path = os.path.join(temp_dir, os.path.basename(script_path))
    shutil.copy(script_path, script_dest_path)
    return script_dest_path

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Execute a command or script through Tor network in a Docker container.")
    parser.add_argument("--python", type=str, help="Python script or command to execute")
    parser.add_argument("--bash", type=str, help="Bash script or command to execute")

    args = parser.parse_args()

    if not (args.python or args.bash):
        print("Usage: python tor_temp_docker.py --python <script_or_command> | --bash <script_or_command>")
        sys.exit(1)

    temp_dir = tempfile.mkdtemp()

    try:
        create_dockerfile(temp_dir)
        create_start_tor_script(temp_dir)
        build_docker_image(temp_dir)

        if args.python:
            if os.path.isfile(args.python):
                script_path = copy_script_to_temp_dir(args.python, temp_dir)
                stdout, stderr = execute_in_docker(f"python3 {script_path}", "python3")
            else:
                stdout, stderr = execute_in_docker(args.python, "python3")
        elif args.bash:
            if os.path.isfile(args.bash):
                script_path = copy_script_to_temp_dir(args.bash, temp_dir)
                stdout, stderr = execute_in_docker(f"bash {script_path}", "bash")
            else:
                stdout, stderr = execute_in_docker(args.bash, "bash")

        print("Output:", stdout)
        print("Error:", stderr)
    finally:
        shutil.rmtree(temp_dir)
