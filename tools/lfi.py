#!/usr/bin/env python3
import re
import subprocess
import time
from termcolor import colored
import argparse
import random
import sys
from urllib.parse import urlparse, urlunparse, parse_qs, urlencode

# Define LFI errors
lfi_errors = ["root:x:", "bin:x", "daemon", "syntax", "bin:x", "mysql_", "mysql", "shutdown", "ftp", "cpanel", "/bin/bash", "/usr/sbin", "www-data", "root:x:0:0:root:", "syslog"]

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
/ /\\ \/ /    \\ \\/\\ \\ \\
\\/ /\/ /      \/ /\/ /
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
         \/\\/
    """
    # print(banner)
    # animated_text("Project Ibrahim LFI Tool", 'blue')

def animated_text(text, color='white', speed=0.0):
    for char in text:
        sys.stdout.write(colored(char, color))
        sys.stdout.flush()
        time.sleep(speed)
    print()

def print_help():
    options = """
+===================================================================================+
       --urls     Provide a urls list for testing
       --payloads Provide a list of lfi payloads for testing
       -s         Rate limit to 12 requests per second
       -h         Display help message and exit.
       -f         Use multi-threading with 10 workers for faster scanning
       -d         Sleep duration in seconds between requests

Example: python script_name.py --urls urls.txt --payloads lfi_payloads.txt -f -s -d 3
+===================================================================================+
"""
    print(colored(options, 'white'))

def random_delay(sleep_seconds):
    if sleep_seconds:
        time.sleep(sleep_seconds)

def scan_url(url, payload, headers):  # Pass a single payload as an argument
    url_components = urlparse(url)
    query_params = parse_qs(url_components.query)

    for key in query_params.keys():
        original_values = query_params[key]

        payload = payload.replace('"', r'\"')

        url_modified = url
        query_params[key] = [payload]
        url_modified = urlunparse((url_components.scheme, url_components.netloc, url_components.path, url_components.params, urlencode(query_params, doseq=True), url_components.fragment))
        query_params[key] = original_values

        command = f'curl -s -i --url "{url_modified}"'
        try:
            output_bytes = subprocess.check_output(command, shell=True)
        except subprocess.CalledProcessError as e:
            print(f"Error accessing {url}: {e.output.decode()}")
            continue

        output_str = output_bytes.decode('utf-8', errors='ignore')

        lfi_matches = [error for error in lfi_errors if error in output_str]
        if lfi_matches:
            message = f"\n{colored('LOCAL FILE INCLUSION ERROR FOUND ON', 'white')} {colored(url_modified, 'red')}"
            with open('lfi_errors.txt', 'a') as file:
                file.write(url_modified+'\n')
            for match in lfi_matches:
                print(colored(" Match Words: " + match, 'cyan'))
            print(message)
        else:
            print(colored(f"{url_modified}: safe", 'green'))

def main():
    parser = argparse.ArgumentParser(description="LFI Tool", add_help=False)
    parser.add_argument("--urls", required=True, help="Provide a urls list for testing", type=str)
    parser.add_argument("--payloads", required=True, help="Provide a list of LFI payloads for testing", type=str)
    parser.add_argument("-s", "--silent", action="store_true", help="Rate limit to 12 requests per second")
    parser.add_argument("-h", "--help", action="store_true", help="Display help message and exit.")
    parser.add_argument("-f", "--fast", action="store_true", help="Use multi-threading with 10 workers for faster scanning")
    parser.add_argument("-d", "--delay", type=int, help="Sleep duration in seconds between requests")

    args = parser.parse_args()

    if args.help:
        print_help()
        exit()

    print_banner()

    with open(args.urls, 'r') as f:
        urls = f.read().splitlines()

    with open(args.payloads, 'r') as f:
        payloads = f.read().splitlines()

    # Randomize the order of URLs
    random.shuffle(urls)

    # Define headers
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate'
    }

    # Test each payload on each URL parameter combination
    for payload in payloads:
        for url in urls:
            print(colored(f"Testing URL: {url}", "red"))
            print(colored(f"Testing Payload: {payload}", "yellow"))
            scan_url(url, payload, headers)
            random_delay(args.delay)

    print("Scanning completed.")

if __name__ == "__main__":
    main()
