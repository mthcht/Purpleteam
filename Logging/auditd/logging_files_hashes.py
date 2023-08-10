import hashlib
import os
import re
import subprocess
import time
import configparser
import argparse

def get_configuration(config_path):
    config = configparser.ConfigParser()
    config.read(config_path)
    return config

def get_monitored_paths(auditctl_path, monitored_paths):
    result = subprocess.run([auditctl_path, '-l'], stdout=subprocess.PIPE, text=True)
    paths = set()
    for line in result.stdout.split('\n'):
        if any(op in line for op in ['-S write', '-S openat', '-S unlink', '-S unlinkat']):
            match = re.search(r'-F dir=(\S+)', line)
            if match:
                path = match.group(1)
                paths.add(path)
    all_files = []
    for path in paths:
        for root, dirs, files in os.walk(path):
            for file in files:
                full_path = os.path.join(root, file)
                all_files.append(full_path)
    return all_files

def calculate_hash(file_path):
    hash_obj = hashlib.sha256()
    with open(file_path, 'rb') as file:
        buffer = file.read(1024)
        while buffer:
            hash_obj.update(buffer)
            buffer = file.read(1024)
    return hash_obj.hexdigest()

def main(config_path):
    config = get_configuration(config_path)
    auditctl_path = config['Paths']['auditctl_path']
    monitored_paths = config['Paths']['monitored_paths'].split(',')
    excluded_paths = config['Paths']['excluded_paths'].split(',')
    frequency_check = int(config['Settings']['frequency_check'])
    log_level = config['Settings']['log_level']
    log_location = config['Settings']['log_location']

    while True:
        paths = get_monitored_paths(auditctl_path, monitored_paths)
        for path in paths:
            timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
            timestamp_epoch = int(time.time())
            if any((excluded_path in path) for excluded_path in excluded_paths):
                if log_level == "debug":
                    with open(log_location, 'a') as log_file:
                        log_file.write(f'{timestamp},{timestamp_epoch},DEBUG,path {path} is ignored\n') 
                    continue
            else:
                if os.path.isfile(path):
                    try:
                        file_hash = calculate_hash(path)
                        with open(log_location, 'a') as log_file:
                            log_file.write(f'{timestamp},{timestamp_epoch},INFO,{path},{file_hash}\n')
                    except Exception as e:
                        log_file.write(f'{timestamp},{timestamp_epoch},ERROR,{path},ERROR : {str(e)}\n')
        time.sleep(frequency_check)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("config_path", help="Path to the configuration file")
    args = parser.parse_args()
    main(args.config_path)
