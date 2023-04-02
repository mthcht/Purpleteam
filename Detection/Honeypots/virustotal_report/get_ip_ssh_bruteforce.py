#!/bin/python3

import csv
import os
import re
import gzip
from datetime import datetime


current_year = datetime.now().year
log_dir = "/var/log/"
bf_list_result = "/opt/virustotal_report/bf_list.csv"
result=[]

def month_to_number(month_name):
    month_dict = {
        "Jan": "01",
        "Feb": "02",
        "Mar": "03",
        "Apr": "04",
        "May": "05",
        "Jun": "06",
        "Jul": "07",
        "Aug": "08",
        "Sep": "09",
        "Oct": "10",
        "Nov": "11",
        "Dec": "12"
    }
    return month_dict.get(month_name, "N/A")

def extract():
    for log_line in log_file:
        if filename.endswith("gz"):
            log_line = log_line.decode("utf-8")
        if "Failed password for" in log_line:
            ip_address = re.findall(r'[0-9]+(?:\.[0-9]+){3}', log_line)
            date_time_day = re.compile(r'^.+?(?=[0-9])(.+?(?=\s))')
            date_time_month = re.findall(r'^.+?(?=\s)', log_line)
            date_time_month = ' '.join(date_time_month)
            date_time_day = date_time_day.match(log_line)
            if ip_address:
                result.append(("[{}/{}/{}]".format(current_year,month_to_number(date_time_month),date_time_day.group(1)),ip_address[0]))

for filename in os.listdir(log_dir):
    if filename.startswith("auth"):
        print(filename)
        if filename.endswith("gz"):
            with gzip.open(os.path.join(log_dir, filename)) as log_file:
                extract()
        else:
            with open(os.path.join(log_dir, filename)) as log_file:
                extract()
        if result:
            result.sort()
            result = list(dict.fromkeys([x for x in result if result.count(x) == 1]))
            print(result)

result_dict = {}
csv_dict = {}
with open(bf_list_result,'r') as f_input:
    csv_input = csv.reader(f_input)
    first_char = f_input.read(1)
    if first_char:
        for row in csv_input:
            csv_dict[row[1]] = row[0]
for num,ip in result:
    if ip not in result_dict:
        result_dict[ip] = num
        #result_dict[month] = month
    elif result_dict[ip] < num:
        result_dict[ip] = num
for ip in csv_dict:
    if ip not in result_dict:
        if ip.startswith("ip") or ip.startswith("date"):
            pass
        else:
            result_dict[ip] = csv_dict[ip]
print('final result:')
print(list(result_dict.items()))
print(result_dict)
with open(bf_list_result,'w') as f_output:
    csv_output = csv.writer(f_output)
    csv_output.writerow(['ip_address','date'])
    for ip,date in result_dict.items():
        csv_output.writerow([ip,date])

with open(bf_list_result,'r') as f_input:
    csv_reader = csv.DictReader(f_input)
    line_count = 0
    for row in csv_reader:
        if line_count == 0:
            print(f'Column names are {", ".join(row)}')
            line_count += 1
        print(f'\t{row["ip_address"]} -  {row["date"]}')
        line_count += 1
    print(f'Processed {line_count} lines.')
