import re
from datetime import datetime

def decode_hex(hex_str):
    return "".join([chr(int(hex_str[i:i+2], 16)) for i in range(0, len(hex_str), 2)]).replace('\x00', ' ')

def get_action_from_syscall(syscall, success):
    action_mapping = {
        '257': 'write_success' if success == 'yes' else 'write_attempt',
        # Add other syscall mappings here as needed
    }
    return action_mapping.get(syscall, 'unknown')

input_file = '/var/log/audit/audit.log'
output_file = 'formatted_output.log'

with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
    current_timestamp = None
    event_data = {}

    for line in infile:
        timestamp_match = re.search(r'msg=audit\((\d+\.\d+):\d+\)', line)
        if timestamp_match:
            timestamp = timestamp_match.group(1)
            if current_timestamp != timestamp and event_data:
                formatted_date = datetime.fromtimestamp(float(current_timestamp)).strftime("%Y/%m/%d %H:%M")
                formatted_line = f"session_id={current_timestamp},date={formatted_date},command='{event_data.get('command')}',file_path={event_data.get('file_path')},working_directory={event_data.get('working_directory')},user_id={event_data.get('user_id')},process_name={event_data.get('process_name')},key=[{event_data.get('formatted_keys')}],action={event_data.get('action')}\n"
                outfile.write(formatted_line)
                event_data = {}

            current_timestamp = timestamp

        # Continue extracting other details as previously:
        syscall_match = re.search(r'syscall=(\d+) success=(\w+)', line)
        if syscall_match:
            syscall, success = syscall_match.groups()
            event_data['action'] = get_action_from_syscall(syscall, success)

        proctitle_match = re.search(r'proctitle=([0-9a-fA-F]+)', line)
        if proctitle_match:
            event_data['command'] = decode_hex(proctitle_match.group(1))

        file_path_match = re.search(r'name="(.*?)" inode', line)
        if file_path_match:
            event_data['file_path'] = file_path_match.group(1)

        cwd_match = re.search(r'cwd="(.*?)"', line)
        if cwd_match:
            event_data['working_directory'] = cwd_match.group(1)

        user_id_match = re.search(r'uid=(\d+)', line)
        if user_id_match:
            event_data['user_id'] = user_id_match.group(1)

        exe_match = re.search(r'exe="(.*?)"', line)
        if exe_match:
            event_data['process_name'] = exe_match.group(1)

        key_match = re.search(r'key="(.*?)"', line)
        if key_match:
            event_data['formatted_keys'] = key_match.group(1)

print(f'Formatted log has been written to {output_file}')
