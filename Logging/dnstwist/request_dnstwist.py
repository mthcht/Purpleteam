import requests
import logging
import csv
import sys
import argparse

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def get_method_and_header(algo, resolved, dnstwist_api_server):
    if resolved:
        method = f"{dnstwist_api_server}/dnstwist_resolved"
        header = ["metadata.algotype", "dest_nt_domain", "dest_ip", "metadata.name_server1", "metadata.mail_server", "metadata.name_server2","metadata.original_domain"]
        algotype = 'resolved'
    else:
        method = f"{dnstwist_api_server}/dnstwist_algo"
        header = ["dest_nt_domain", "metadata.original_domain"]
        algotype = 'algo'
    return method, header, algotype

def query_dnstwist(method,domain):
    try:
        response = requests.post(method, json={'domain': domain})
        response.raise_for_status()
        return response.text
    except requests.RequestException as e:
        logging.error(f"An error occurred while querying dnstwist for {domain}: {e}")
        return None

def save_to_csv(algotype,header, data, domain):
    filename = f"SOC_DNSTWIST_{domain}_List.csv"
    try:
        with open(filename, 'w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(header)
            if algotype == 'algo':
                rows = data.split('\n')
            if algotype == 'resolved':
                rows = data.split('\n')[1:]
            for line in rows:
                if line:
                    writer.writerow(line.split(',') + [domain])
        logging.info(f"Results saved to {filename}")
    except Exception as e:
        logging.error(f"An error occurred while saving to CSV for {domain}: {e}")

def main():
    parser = argparse.ArgumentParser(description='Client script for dnstwist.')
    parser.add_argument('domains', nargs='+', help='List of domains to process')
    parser.add_argument('--algo', action='store_true', help='Execute the algo function')
    parser.add_argument('--resolved', action='store_true', help='Execute the resolved function (will make thousands of dns requests)')
    args = parser.parse_args()
    dnstwist_api_server = 'http://127.0.0.1:443'

    if not args.domains:
        logging.error("Please provide at least one domain as an argument")
        return
    if not args.resolved and not args.algo:
        args.algo=True

    for domain in args.domains:
        logging.info(f"Querying dnstwist for domain: {domain}")     
        method, header, algotype = get_method_and_header(args.algo, args.resolved, dnstwist_api_server)
        result = query_dnstwist(method,domain)
        if result:
            save_to_csv(algotype, header, result, domain)
        else:
            logging.error(f"Failed to retrieve data from dnstwist for {domain}")

if __name__ == '__main__':
    main()
