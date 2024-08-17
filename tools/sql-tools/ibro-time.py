#!/usr/bin/env python3
import requests
import chardet
import urllib.parse
import random
import time
import subprocess
from termcolor import colored
import argparse
import sys
import re
import logging

total_attempts = 0
current_progress = 0

def animated_text(text, color='white', speed=0):
    for char in text:
        sys.stdout.write(colored(char, color))
        sys.stdout.flush()
        time.sleep(speed)
    print()

def random_delay():
    if args.silent:
        time.sleep(60/12)
    else:
        base_delay = 1
        jitter = random.uniform(0.5, 1.5)
        time.sleep(base_delay * jitter)

def print_banner():
    banner = """
         /\\/\\
        /  \\ \\
       / /\\ \\ \\
       \\/ /\\/ /
       / /\\/ /\\
      / /\\ \\/\\ \\
     / / /\\ \\ \\ \\
  /\\/ / / /\\ \\ \\ \\/\\
 /  \\/ / /  \\ \\ \\ \\ \\
/ /\ \/ /    \\ \\/\\ \\ \\
\/ /\/ /      \\/ /\/ /
/ /\/ /\\      / /\/ /\\
\\ \\ \\/\\ \\    / /\\ \\/ /
 \\ \\ \\ \\ \\  / / /\\  /
  \\/\\ \\ \\ \\/ / / /\\/
     \\ \\ \\ \/ / /
      \\ \\/\\ \/ /
       \\/ /\/ /
       / /\/ /\\
       \\ \\ \/ /
        \\ \\  /
         \\/\\/
"""
    # print(banner)
    # animated_text("Project IbrahimSQLi Time-Based Tool", 'blue')
    options = """
+===================================================================================+
       --urls     Provide a urls list for testing
       --payloads Provide a list of sqli payloads for testing
       -s         Rate limit to 12 requests per second
       -h         Display this help message
       -f         Use multi-threading for faster scanning

Example: python ibrahimsql.py --urls urls.txt --payloads sqli_payloads.txt 
+===================================================================================+
"""
    print(colored(options, 'white'))

parser = argparse.ArgumentParser(description="SQLi Time-Based Tool by Ibrahim Husic", add_help=False)
parser.add_argument("--urls", required=True, help="Provide a urls list for testing", type=str)
parser.add_argument("--payloads", required=True, help="Provide a list of sqli payloads for testing", type=str)
parser.add_argument("-s", "--silent", action="store_true", help="Rate limit to 12 requests per second")
parser.add_argument("-h", "--help", action="store_true", help="Display help message and exit.")
parser.add_argument("-f", "--fast", action="store_true", help="Use multi-threading for faster scanning")

print_banner()
args = parser.parse_args()

if args.help:
    exit()

with open(args.urls, "rb") as f:
    raw_data = f.read()
    result = chardet.detect(raw_data)
    encoding = result["encoding"]

with open(args.urls, "r", encoding=encoding) as f:
    urls = [line.strip() for line in f.readlines()]

with open(args.payloads, "r") as f:
    payloads = [line.strip() for line in f.readlines()]

# Calculate total number of query parameters across all URLs
total_query_params = sum(url.count('&') + 1 for url in urls)
print(f"Total query parameters across all URLs: {total_query_params}")

# Calculate total number of requests
total_number_of_payloads = len(payloads)
total_requests = total_query_params * total_number_of_payloads
print(f"Total number of payloads: {total_number_of_payloads}")
print(f"Total requests: {total_requests}")

vulnerable_urls = []
progress = 0

# Configure logging to write to error_log.txt file
logging.basicConfig(filename='error_log.txt', level=logging.ERROR)

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
        except ValueError as e:
            # Log the error for debugging purposes
            logging.error(f"An error occurred while converting time string: {e}")
            print(colored(f"Invalid time format: {time_str}", "red"))
            return None

# Initialize total_attempts counter
total_attempts = 0

# Function to extract sleep time from payload
def extract_sleep_time(payload):
    # Regular expression pattern to extract sleep time
    pattern = r'sleep\s*\(\s*(\d+|\d+\s*[*]\s*\d+)\s*\)'
    sleep_time_match = re.search(pattern, payload, re.IGNORECASE)
    if sleep_time_match:
        # Extract sleep time from the matched group
        sleep_time = eval(sleep_time_match.group(1))
        return sleep_time
    else:
        return None

# Function to scan URL and payload
def scan_url(url, payload):
    global progress, total_attempts
    try:
        base_url, query_string = url.split('?', 1)
    except ValueError:
        # If no query string is found, use the entire URL as the base URL
        base_url = url
        query_string = ''
    pairs = query_string.split('&')
    for i in range(len(pairs)):
        modified_pairs = pairs.copy()
        if '=' in modified_pairs[i]:
            key, value = modified_pairs[i].split('=', 1)
            modified_pairs[i] = f"{key}={payload}"
        request_url = f"{base_url}?{'&'.join(modified_pairs)}"
        try:
            # Construct and execute the time curl command
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3',
                'Accept-Language': 'en-US,en;q=0.5',
                'Accept-Encoding': 'gzip, deflate'
            }
            response = requests.get(request_url, headers=headers, timeout=40)
            response_time = response.elapsed.total_seconds()
            sleep_time = extract_sleep_time(payload)
            if sleep_time is not None and response_time >= (sleep_time - 3) and response_time <= (sleep_time + 3):
                # Print the detection message
                print(colored("Time-based SQL Injection FOUND:", "white"))
                output = f"URL: {url}\nPAYLOAD: {payload}\nPARAMETER: {modified_pairs[i]}\nTIME DELAY: {response_time} seconds\n"
                print(colored(output, "blue"))
                with open('time-based_vulnerable_urls.txt', 'a') as file:
                    file.write(output)
            else:
                print(colored(f"Response time: {response_time} seconds", "white"))
                print(colored("Payload format recognized but sleep time comparison failed.", "yellow"))
            progress += 1
            percent_complete = round(progress / total_requests * 100, 2)
            print(f"{colored('Progress:', 'blue')} {progress}/{total_requests} ({percent_complete}%)")
            # Increment total_attempts for each request made
            total_attempts += 1
        except requests.Timeout:
            print(colored(f"Request to URL {url} timed out after 40 seconds. Moving to the next URL.", "red"))
            break
        except Exception as e:
            # Print the error message
            print(f"An error occurred while testing URL {url} with payload {payload}: {e}")
            # Log the error to a file for further analysis
            logging.error(f"An error occurred while testing URL {url} with payload {payload}: {e}")
            # Continue testing other URLs and payloads
            progress += 1
            percent_complete = round(progress / total_requests * 100, 2)
            print(f"{colored('Progress:', 'blue')} {progress}/{total_requests} ({percent_complete}%)")

# Randomize the order of URLs
random.shuffle(urls)

# Test each payload on each URL parameter combination
for payload in payloads:
    for url in urls:
        print(colored(f"Testing URL: {url}", "red"))
        print(colored(f"Testing Payload: {payload}", "yellow"))
        scan_url(url, payload)

start_time = time.time()

end_time = time.time()
total_time = end_time - start_time

print("Scanning completed.")
print(f"Total requests made: {total_attempts}")
print(f"Total time taken: {total_time} seconds")
