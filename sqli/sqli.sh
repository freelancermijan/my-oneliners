#!/usr/bin/env bash

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -s http://example.com"
    echo ""
    echo "Options:"
    echo "  -h               Display this help message"
    echo "  -s               Single site scan"
    echo "  -sf              Fast scan for single site scan"
    echo "  -m               Multiple site scan"
    echo "  -mf              Multiple site fast scan"
    echo "  -i               Check if required tools are installed"
    echo ""
    echo "Required Tools:"
    echo "              https://github.com/projectdiscovery/subfinder
              https://github.com/freelancermijan/bsqli
              https://github.com/projectdiscovery/subfinder
              https://github.com/xnl-h4ck3r/waymore
              https://github.com/tomnomnom/qsreplace
              https://github.com/projectdiscovery/katana
              https://github.com/s0md3v/uro
              https://github.com/projectdiscovery/httpx"
    exit 0
}

# Function to check installed tools
check_tools() {
    tools=("sqlmap" "bsqli" "subfinder" "gf" "uro" "ghauri" "waymore" "katana" "qsreplace" "httpx")

    echo "Checking required tools:"
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            echo "$tool is installed at $(which $tool)"
        else
            echo "$tool is NOT installed or not in the PATH"
        fi
    done
}


# Check if help is requested
if [[ "$1" == "-h" ]]; then
    display_usage
    exit 0
fi

# Check if tool installation check is requested
if [[ "$1" == "-i" ]]; then
    check_tools
    exit 0
fi


if [[ "$1" == "-sf" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,')

    mkdir -p bug_bounty_report/$domain_Without_Protocol/sqli/

    echo ""
    echo "=================================================================="
    echo "========== Fast scan for single site parameter finding ==========="
    echo "=================================================================="
    echo ""

    katana -u "$domain_Without_Protocol" -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -sf fqdn -f qurl -aff -ef js,css | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | uro -b js css >>bug_bounty_report/$domain_Without_Protocol/sqli/all.sf.parameters.txt

    cat bug_bounty_report/$domain_Without_Protocol/sqli/all.sf.parameters.txt | gf sqli | uro -b js css | tee bug_bounty_report/$domain_Without_Protocol/sqli/sqli.sf.parameters.txt
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/sqli/sqli.sf.parameters.txt | wc -l

    echo ""
    echo "=================================================================="
    echo "====== Fast scan for single site parameter finding finished ======"
    echo "=================================================================="
    echo ""

    echo ""
    echo "=================================================================="
    echo "========= Fast scan for single site SQL Detecting ================"
    echo "=================================================================="
    echo ""
    bsqli --urls bug_bounty_report/$domain_Without_Protocol/sqli/sqli.sf.parameters.txt --payloads payloads/xor.txt --verbose --save bug_bounty_report/$domain_Without_Protocol/sqli/detected.sf.sql.urls.txt
    echo ""
    echo "=================================================================="
    echo "====== Fast scan for single site SQL Detecting finished =========="
    echo "=================================================================="
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/sqli/detected.sf.sql.urls.txt
    exit 0

fi

if [[ "$1" == "-s" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,')

    mkdir -p bug_bounty_report/$domain_Without_Protocol/sqli/

    echo ""
    echo "=================================================================="
    echo "========== Single site parameter finding ========================="
    echo "=================================================================="
    echo ""

    waymore -i "$domain_Without_Protocol" -n -mode U | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | uro -b js css >>bug_bounty_report/$domain_Without_Protocol/sqli/all.parameters.txt

    cat bug_bounty_report/$domain_Without_Protocol/sqli/all.parameters.txt | gf sqli | uro -b js css | tee bug_bounty_report/$domain_Without_Protocol/sqli/sqli.parameters.txt
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
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,')

    mkdir -p bug_bounty_report/$domain_Without_Protocol/sqli/
    echo ""
    echo "=================================================================="
    echo "========= Multiple site parameter finding ========================"
    echo "=================================================================="
    echo ""

    subfinder -d "$domain_Without_Protocol" -recursive -all -o bug_bounty_report/$domain_Without_Protocol/sqli/m_subdomains.txt

    httpx -l bug_bounty_report/$domain_Without_Protocol/sqli/m_subdomains.txt -mc 200,301,302,401,403,500 | sed -e 's~http://~~g' -e 's~https://~~g' -e 's~www\.~~g' | tee bug_bounty_report/$domain_Without_Protocol/sqli/alive.subdomains.txt

    cat bug_bounty_report/$domain_Without_Protocol/sqli/alive.subdomains.txt | while read domain; do waymore -i "$domain" -n -mode U | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | uro -b js css >> bug_bounty_report/$domain_Without_Protocol/sqli/m_all.parameters.txt; done

    cat bug_bounty_report/$domain_Without_Protocol/sqli/m_all.parameters.txt | gf sqli | uro -b js css | tee bug_bounty_report/$domain_Without_Protocol/sqli/m_sqli.parameters.txt

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


if [[ "$1" == "-mf" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,')

    mkdir -p bug_bounty_report/$domain_Without_Protocol/sqli/
    echo ""
    echo "=================================================================="
    echo "========= Multiple site parameter finding ========================"
    echo "=================================================================="
    echo ""

    subfinder -d "$domain_Without_Protocol" -recursive -all -o bug_bounty_report/$domain_Without_Protocol/sqli/mf_subdomains.txt

    httpx -l bug_bounty_report/$domain_Without_Protocol/sqli/mf_subdomains.txt -mc 200,301,302,401,403,500 | sed -e 's~http://~~g' -e 's~https://~~g' -e 's~www\.~~g' | tee bug_bounty_report/$domain_Without_Protocol/sqli/mf.alive.subdomains.txt


    katana -list bug_bounty_report/$domain_Without_Protocol/sqli/mf.alive.subdomains.txt -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -sf fqdn -f qurl -aff -ef js,css | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | uro -b js css >>bug_bounty_report/$domain_Without_Protocol/sqli/all.mf.parameters.txt


    cat bug_bounty_report/$domain_Without_Protocol/sqli/all.mf.parameters.txt | gf sqli | uro -b js css | tee bug_bounty_report/$domain_Without_Protocol/sqli/mf_sqli.parameters.txt

    cat bug_bounty_report/$domain_Without_Protocol/sqli/mf_sqli.parameters.txt | wc -l


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
    bsqli --urls bug_bounty_report/$domain_Without_Protocol/sqli/mf_sqli.parameters.txt --payloads payloads/sleeps.txt --verbose --save bug_bounty_report/$domain_Without_Protocol/sqli/mf_detected.sql.urls.txt
    echo ""
    echo "=================================================================="
    echo "========= Multiple site SQL Detecting finished ==================="
    echo "=================================================================="
    echo ""
    
    cat bug_bounty_report/$domain_Without_Protocol/sqli/mf_detected.sql.urls.txt
    
    exit 0

fi
