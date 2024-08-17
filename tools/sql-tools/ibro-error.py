#!/usr/bin/env python3
import re
import subprocess
import time
from termcolor import colored
import argparse
from concurrent.futures import ThreadPoolExecutor
import random
import sys

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
\\/ /\/ /      \\/ /\/ /
/ /\/ /\\      / /\/ /\\
\\ \\ \\/\\ \\    / /\\ \\/ /
 \\ \\ \\ \\ \\  / / /\\  /
  \\/\\ \\ \\ \\/ / / /\\/
     \\ \\ \\ \\/ / /
      \\ \\/\\ \\/ /
       \\/ /\/ /
       / /\/ /\\
       \\ \\ \\/ /
        \\ \\  /
         \\/\\/
    """
    # print(banner)
    # animated_text("Project IbrahimSQLi Time-Based Tool", 'blue')

def animated_text(text, color='white', speed=0):
    for char in text:
        sys.stdout.write(colored(char, color))
        sys.stdout.flush()
        time.sleep(speed)
    print()

def print_help():
    options = """
+===================================================================================+
       --urls     Provide a urls list for testing
       --payloads Provide a list of sqli payloads for testing
       -s         Rate limit to 12 requests per second
       -h         Display help message and exit.
       -f         Use multi-threading for faster scanning

Example: python script_name.py --urls urls.txt --payloads sqli_payloads.txt 
+===================================================================================+
"""
    print(colored(options, 'white'))

def random_delay():
    if args.silent:
        time.sleep(60/12)
    else:
        base_delay = 1
        jitter = random.uniform(0.5, 1.5)
        time.sleep(base_delay * jitter)

parser = argparse.ArgumentParser(description="SQLi Error-Based Tool", add_help=False)
parser.add_argument("--urls", required=True, help="Provide a urls list for testing", type=str)
parser.add_argument("--payloads", required=True, help="Provide a list of sqli payloads for testing", type=str)
parser.add_argument("-s", "--silent", action="store_true", help="Rate limit to 12 requests per second")
parser.add_argument("-h", "--help", action="store_true", help="Display help message and exit.")
parser.add_argument("-f", "--fast", action="store_true", help="Use multi-threading for faster scanning")

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

sql_errors = ["Syntax error", "Fatal error", "MariaDB", "corresponds", "Database Error", "syntax", "/usr/www", "public_html", "database error", "on line", "RuntimeException", "mysql_", "MySQL", "PSQLException", "at line", "You have an error in your SQL syntax", "mysql_query()", "pg_connect()", "SQLiteException", "ORA-", "invalid input syntax for type", "unterminated quoted string", "PostgreSQL query failed:", "unrecognized token:", "binding parameter", "undeclared variable:", "SQLSTATE", "constraint failed", "ORA-00936: missing expression", "ORA-06512:", "PLS-", "SP2-", "dynamic SQL error", "SQL command not properly ended", "T-SQL Error", "Msg ", "Level ", "Unclosed quotation mark after the character string", "quoted string not properly terminated", "Incorrect syntax near", "An expression of non-boolean type specified in a context where a condition is expected", "Conversion failed when converting", "Unclosed quotation mark before the character string", "SQL Server", "OLE DB", "Unknown column", "Access violation", "No such host is known", "server error", "syntax error at or near", "column does not exist", "could not prepare statement", "no such table:", "near \"Syntax error\": syntax error", "unknown error", "unexpected end of statement", "ambiguous column name", "database is locked", "permission denied", "attempt to write a readonly database", "out of memory", "disk I/O error", "cannot attach the file", "operation is not allowed in this state", "data type mismatch", "cannot open database", "table or view does not exist", "index already exists", "index not found", "division by zero", "value too large for column", "deadlock detected", "invalid operator", "sequence does not exist", "duplicate key value violates unique constraint", "string data, right truncated", "insufficient privileges", "missing keyword", "too many connections", "configuration limit exceeded", "network error while attempting to read from the file", "cannot rollback - no transaction is active", "feature not supported", "system error", "object not in prerequisite state", "login failed for user", "remote server is not known"]

time_pattern = re.compile(r"elapsed (\d+:\d+\.\d+)")

total_requests = len(urls) * len(payloads) * max(url.count('&') + 1 for url in urls)
progress = 0
start_time = time.time()

def scan_url(url):
    base_url, query_string = url.split('?', 1) if '?' in url else (url, '')
    pairs = query_string.split('&')
    for payload in payloads:
        payload = payload.replace("'", "%27")
        for i in range(len(pairs)):
            modified_pairs = pairs.copy()
            if '=' in modified_pairs[i]:
                key, value = modified_pairs[i].split('=', 1)
                modified_pairs[i] = f"{key}={payload}"
            url_modified = f"{base_url}?{'&'.join(modified_pairs)}"
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3',
                'Accept-Language': 'en-US,en;q=0.5',
                'Accept-Encoding': 'gzip, deflate'
            }
            command = ['curl', '-s', '-i', '--url', url_modified]
            output_bytes = None
            try:
                output_bytes = subprocess.check_output(command, stderr=subprocess.DEVNULL)
            except subprocess.CalledProcessError:
                pass
            if output_bytes is not None:
                output_str = output_bytes.decode('utf-8', errors='ignore')
                sql_matches = [error for error in sql_errors if error in output_str]
                if sql_matches:
                    message = f"\n{colored('SQL ERROR FOUND', 'white')} ON {colored(url_modified, 'red', attrs=['bold'])} with payload {colored(payload, 'white')}"
                    with open('sql_errors.txt', 'a') as file:
                        file.write(url_modified + '\n')
                    for match in sql_matches:
                        print(colored(" Match Words: " + match, 'cyan'))
                    print(message)
                else:
                    print(colored(f"URL: {url_modified} | Payload: {payload} | Status: safe", 'green'))
            random_delay()
            global progress
            progress += 1
            elapsed_seconds = time.time() - start_time
            remaining_seconds = (total_requests - progress) * (elapsed_seconds / progress)
            remaining_hours = int(remaining_seconds // 3600)
            remaining_minutes = int((remaining_seconds % 3600) // 60)
            percent_complete = round(progress / total_requests * 100, 2)
            print(f"{colored('Progress:', 'blue')} {progress}/{total_requests} ({percent_complete}%) - {remaining_hours}h:{remaining_minutes:02d}m")

if args.fast:
    with ThreadPoolExecutor(max_workers=20) as executor:
        executor.map(scan_url, urls)
else:
    for url in urls:
        scan_url(url)

end_time = time.time()
total_time = end_time - start_time
print("Scanning completed.")
print(f"Total time taken: {total_time} seconds")
