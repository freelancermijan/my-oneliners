#!/usr/bin/env python3
import requests
import argparse
import time
from termcolor import colored
from requests.exceptions import ReadTimeout

def load_file(file_path):
    with open(file_path, 'r') as file:
        return [line.strip() for line in file]

def format_response_time(response_time):
    minutes = int(response_time // 60)
    seconds = int(response_time % 60)
    return f"{minutes:02}:{seconds:02}"

def check_vulnerability(url, payload, delay, output_file):
    try:
        full_url = url + payload
        start_time = time.time()
        response = requests.get(full_url, timeout=delay + 10)
        end_time = time.time()
        response_time = end_time - start_time

        formatted_time = format_response_time(response_time)

        if response_time >= delay:
            message = f"Vulnerable URL Found: {full_url} | Response Time: {formatted_time} seconds"
            print(colored(message, "red"))
            if output_file:
                with open(output_file, 'a') as file:
                    file.write(f"{full_url}\n")
        else:
            message = f"URL Checked: {full_url} | Response Time: {formatted_time} seconds"
            print(colored(message, "green"))
    except ReadTimeout:
        end_time = time.time()
        response_time = end_time - start_time
        formatted_time = format_response_time(response_time)
        message = f"Vulnerable URL Found: {full_url} | Response Time: {formatted_time} seconds"
        print(colored(message, "red"))
        if output_file:
            with open(output_file, 'a') as file:
                file.write(f"{full_url}\n")
    except requests.exceptions.RequestException as e:
        message = f"Error checking URL {full_url}: {e}"
        print(colored(message, "red"))

def main():
    parser = argparse.ArgumentParser(description='Blind SQL Injection Checker')
    parser.add_argument('-l', '--urls', required=True, help='File containing list of URLs')
    parser.add_argument('-p', '--payloads', required=True, help='File containing list of payloads')
    parser.add_argument('-t', '--time', type=int, default=5, help='Time delay to check for (in seconds, default is 5)')
    parser.add_argument('-o', '--output', help='File to output vulnerable URLs')
    args = parser.parse_args()

    urls = load_file(args.urls)
    payloads = load_file(args.payloads)
    delay = args.time
    output_file = args.output

    for url in urls:
        for payload in payloads:
            check_vulnerability(url, payload, delay, output_file)

if __name__ == "__main__":
    main()
