#!/bin/python3

import requests
import csv

api_key = "FIXME"
url_comment_ip = "https://www.virustotal.com/api/v3/ip_addresses/{}/comments"
url_vote_ip = "https://www.virustotal.com/api/v3/ip_addresses/{}/votes"
ip_wl =  '/opt/virustotal_report/ssh/ip_reported_wl.csv'
bf_list = '/opt/virustotal_report/ssh/bf_list.csv'

headers = {
    "accept": "application/json",
    "content-type": "application/json",
    "x-apikey": api_key
}

def add_to_wl(filename, new_value):
    existing_values = []
    with open(filename, 'r') as file:
        reader = csv.reader(file)
        for row in reader:
            existing_values.append(row[0])
    with open(filename, 'a+', newline='') as file:
        writer = csv.writer(file)
        if new_value not in existing_values:
            writer.writerow([new_value])
            print(f"Successfully wrote '{new_value}' to '{filename}'")
        else:
            print(f"'{new_value}' already exists in '{filename}', skipping write")

def check_reported(filename, new_value):
    existing_values = []
    with open(filename, 'r') as file:
        reader = csv.reader(file)
        for row in reader:
            existing_values.append(row[0])
    if new_value not in existing_values:
        return "ok"

def post_comment_on_ip(date,ip_address):
        url = url_comment_ip.format(ip_address)
        response = requests.post(url, json= {"data": {"type": "comment","attributes": {"text": "{} Bruteforce SSH - Password spraying from {}".format(date,ip_address)}}}, headers=headers)
        if response.status_code == 200:
            print(f"Comment posted on IP: {ip_address}")
            add_to_wl(ip_wl,"{},{}".format(ip_address,date))
        elif response.status_code == 429:
            print(f"Failed to post comment on IP: {ip_address}. Error: {response.text} {response.status_code} Too many request check quota limit... \n Exiting script...")
            quit()
        else:
            print(f"Failed to post comment on IP: {ip_address}. Error: {response.status_code}  {response.text}")

def give_bad_vote(ip_address):
    url = url_vote_ip.format(ip_address)
    payload = {"data": {
            "type": "vote",
            "attributes": {"verdict": "malicious"}
        }}
    headers = {
        "accept": "application/json",
        "x-apikey": api_key,
        "content-type": "application/json"
    }
    response = requests.post(url, json=payload, headers=headers)
    print(response.text)

def main():
    with open(bf_list,'r') as f_input:
        csv_reader = csv.DictReader(f_input)
        line_count = 0
        for row in csv_reader:
            if line_count == 0:
                print(f'Column names are {", ".join(row)}')
                line_count += 1
            print(f'\t{row["ip_address"]} -  {row["date"]}')
            ip_address = row["ip_address"]
            date = row["date"]
            if check_reported(ip_wl,"{},{}".format(ip_address,date)) == "ok":
                print("[Info] Giving a bad vote to {}...".format(ip_address))
                give_bad_vote(ip_address)
                print("[Info] Posting comment for the IP address {}".format(ip_address))
                post_comment_on_ip(date,ip_address)
            else:
                print(f"[Info] '{ip_address}','{date}' already reported to virustotal")
            line_count += 1
main()
