#!/usr/bin/env bash

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -s http://example.com"
    echo ""
    echo "Options:"
    echo "  -h               Display this help message"
    echo "  -s               Single site scan"
    echo "  -m               Multiple site scan"
    echo ""
    echo "Required Tools:"
    echo "              https://github.com/projectdiscovery/subfinder
              https://github.com/coffinsp/customBsqli
              https://github.com/projectdiscovery/subfinder
              https://github.com/xnl-h4ck3r/waymore
              https://github.com/tomnomnom/qsreplace"
    exit 0
}

if [[ "$1" == "-h" ]]; then
    display_usage
    exit 0
fi


if [[ "$1" == "-s" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,;')

    mkdir -p bug_bounty_report/$domain_Without_Protocol/sqli/

    echo ""
    echo "=================================================================="
    echo "========== Single site parameter finding ========================="
    echo "=================================================================="
    echo ""

    waymore -i "$domain_Without_Protocol" -fc 301,302,303,304,307,308 -n -mode U | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee bug_bounty_report/$domain_Without_Protocol/sqli/all.parameters.txt

    cat bug_bounty_report/$domain_Without_Protocol/sqli/all.parameters.txt | gf sqli | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee bug_bounty_report/$domain_Without_Protocol/sqli/sqli.parameters.txt
    cat bug_bounty_report/$domain_Without_Protocol/sqli/sqli.parameters.txt | wc -l

    echo ""
    echo "=================================================================="
    echo "============= Single site parameter finding finished ============="
    echo "=================================================================="
    echo ""

    echo ""
    echo "=================================================================="
    echo "========= Single site SQL Detecting =============================="
    echo "=================================================================="
    echo ""
    bsqli --urls bug_bounty_report/$domain_Without_Protocol/sqli/sqli.parameters.txt --payloads payloads/xor.txt --verbose --save bug_bounty_report/$domain_Without_Protocol/sqli/detected.sql.urls.txt
    echo ""
    echo "=================================================================="
    echo "========= Single site SQL Detecting finished ====================="
    echo "=================================================================="
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/sqli/detected.sql.urls.txt
    exit 0

fi

if [[ "$1" == "-m" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,;')

    mkdir -p bug_bounty_report/$domain_Without_Protocol/sqli/
    echo ""
    echo "=================================================================="
    echo "========= Multiple site parameter finding ========================"
    echo "=================================================================="
    echo ""

    subfinder -d "$domain_Without_Protocol" -recursive -all -o bug_bounty_report/$domain_Without_Protocol/sqli/m_subdomains.txt

    cat bug_bounty_report/$domain_Without_Protocol/sqli/m_subdomains.txt | while read domain; do waymore -i "$domain" -fc 301,302,303,304,307,308 -n -mode U | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee bug_bounty_report/$domain_Without_Protocol/sqli/m_all.parameters.txt; done

    cat bug_bounty_report/$domain_Without_Protocol/sqli/m_all.parameters.txt | gf sqli | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee bug_bounty_report/$domain_Without_Protocol/sqli/m_sqli.parameters.txt

    cat bug_bounty_report/$domain_Without_Protocol/sqli/m_sqli.parameters.txt | wc -l


    echo ""
    echo "=================================================================="
    echo "=========== Multiple site parameter finding finished ============="
    echo "=================================================================="
    echo ""

    echo ""
    echo "=================================================================="
    echo "========= Multiple site SQL Detecting ============================"
    echo "=================================================================="
    echo ""
    bsqli --urls bug_bounty_report/$domain_Without_Protocol/sqli/m_sqli.parameters.txt --payloads payloads/xor.txt --verbose --save bug_bounty_report/$domain_Without_Protocol/sqli/m_detected.sql.urls.txt
    echo ""
    echo "=================================================================="
    echo "========= Multiple site SQL Detecting finished ==================="
    echo "=================================================================="
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/sqli/m_detected.sql.urls.txt
    exit 0

fi