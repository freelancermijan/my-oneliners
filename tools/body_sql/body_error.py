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

# Disable SSL certificate warnings
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
warnings.filterwarnings("ignore", category=UserWarning, module="bs4")

# Global definition of default values
default_values = {
    'username': 'NerminKahrimanovic',
    'password': 'NerminKahrimanovic',
    'name': 'NerminKahrimanovic',
    'surname': 'NerminKahrimanovic',
    'phone_number': '38561324271',
    'city': 'NerminKahrimanovic',
    'email': 'ibrahimnerminnnb@gmail.com',
    'first_name': 'Nermin',
    'last_name': 'Kahrimanovic',
    'job_role': 'Software Developer',
    'company_name': 'NerminCorp'
}

# Define SQL errors in one line
sql_errors = ["Syntax error", "Fatal error", "MariaDB", "corresponds", "Database Error", "syntax", "/usr/www", "occured", "public_html", "database error", "on line", "RuntimeException", "mysql_", "MySQL", "PSQLException", "at line", "You have an error in your SQL syntax", "mysql_query()", "pg_connect()", "SQLiteException", "ORA-", "invalid input syntax for type", "unterminated quoted string", "PostgreSQL query failed:", "unrecognized token:", "binding parameter", "undeclared variable:", "SQLSTATE", "constraint failed", "ORA-00936: missing expression", "ORA-06512:", "PLS-", "SP2-", "dynamic SQL error", "SQL command not properly ended", "T-SQL Error", "Msg ", "Level ", "State ", "Unclosed quotation mark after the character string", "quoted string not properly terminated", "Incorrect syntax near", "An expression of non-boolean type specified in a context where a condition is expected", "Conversion failed when converting", "Unclosed quotation mark before the character string", "SQL Server", "OLE DB", "Unknown column", "Access violation", "No such host is known", "server error", "syntax error at or near", "column does not exist", "could not prepare statement", "no such table:", "near \"Syntax error\": syntax error", "unknown error", "unexpected end of statement", "ambiguous column name", "locked", "database is locked", "permission denied", "attempt to write a readonly database", "out of memory", "disk I/O error", "cannot attach the file", "operation is not allowed in this state", "data type mismatch", "cannot open database", "table or view does not exist", "index already exists", "index not found", "division by zero", "value too large for column", "deadlock detected", "invalid operator", "sequence does not exist", "duplicate key value violates unique constraint", "string data, right truncated", "insufficient privileges", "missing keyword", "too many connections", "configuration limit exceeded", "network error while attempting to read from the file", "cannot rollback - no transaction is active", "feature not supported", "system error", "object not in prerequisite state", "login failed for user", "remote server is not known"]

# Function to scan a single URL form
def scan_url_form(url, payloads, progress, total_requests):
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
    form_parameters = []

    if form:
        form_parameters = [input_field.get('name') for input_field in form.find_all('input', {'type': ['text', 'password', 'email', 'number']}) if input_field.get('name')]
        form_parameters.extend([textarea.get('name') for textarea in form.find_all('textarea') if textarea.get('name')])
        form_parameters.extend([select.get('name') for select in form.find_all('select') if select.get('name')])

        for param in form_parameters:
            for payload in payloads:
                data = {key: default_values.get(key, '') for key in form_parameters}
                data[param] = payload

                new_response = session.post(url, data=data, headers=headers, verify=False)

                if any(error in new_response.text for error in sql_errors):
                    found_errors = [error for error in sql_errors if error in new_response.text]
                    error_str = ', '.join(found_errors)  # Concatenate all found errors into a single string
                    print(colored("Error-based SQL Injection FOUND on:", "blue"))
                    output = f"URL: {url}\nPARAMETER: {param}\nPAYLOAD: {payload}\nSQL ERROR: {error_str}\n"
                    print(colored(output, "blue"))
                    with open('vulnerable_parameters.txt', 'a') as file:
                        file.write("Error-based SQL Injection FOUND on:\n" + output)

                    for error in found_errors:
                        print(colored("SQLI ERROR FOUND ON BODY PARAMETER", "white"))
                        print(colored(error, "white"))
                        with open('hacked_body_error.txt', 'a') as file:
                            file.write(f"URL: {url}, PARAMETER: {param}, PAYLOAD: {payload}, ERROR: {error}\n")

                progress['value'] += 1
                elapsed_time = time.time() - progress['start_time']
                remaining_requests = total_requests - progress['value']
                estimated_total_time = elapsed_time * total_requests / progress['value']
                remaining_time = estimated_total_time - elapsed_time
                remaining_minutes, remaining_seconds = divmod(remaining_time, 60)
                print(f"{colored('Progress:', 'blue')} {progress['value']}/{total_requests} - Remaining time: {int(remaining_minutes)}m {int(remaining_seconds)}s")

    else:
        print("No form found in the response body.")

    return len(payloads) * len(form_parameters) if form_parameters else 0

# Function to handle a single URL
def handle_url(url, payloads, progress, total_requests):
    requests_for_url = scan_url_form(url, payloads, progress, total_requests)
    return requests_for_url

# Main function
def main():
    parser = argparse.ArgumentParser(description='Scan URLs for SQL injection vulnerabilities.')
    parser.add_argument('-f', '--fast', action='store_true', help='Enable fast scanning with multithreading.')
    args = parser.parse_args()

    with open('urls.txt', 'r') as file:
        urls = [url.strip() for url in file.readlines()]

    with open('manual.txt', 'r') as file:
        payloads = [line.strip() for line in file.readlines()]

    progress = {'value': 0, 'start_time': time.time()}
    total_requests = len(urls) * len(payloads)

    if args.fast:
        threads = []
        for url in urls:
            t = threading.Thread(target=handle_url, args=(url, payloads, progress, total_requests))
            threads.append(t)
            t.start()

        for t in threads:
            t.join()
    else:
        for url in urls:
            handle_url(url, payloads, progress, total_requests)

    print(f"Total number of requests made: {progress['value']}")

if __name__ == "__main__":
    main()
