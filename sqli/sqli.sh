#!/usr/bin/env bash

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -s http://example.com"
    echo ""
    echo "Options:"
    echo "  -h               Display this help message"
    echo "  -s               Single site scan(katana, waymore)"
    echo "  -m               Multiple site scan(katana, waymore)"
    echo "  -ml              Multiple list site scan (katana, waymore, subfinder, sublist3r)"
    echo "  -i               Check if required tools are installed"
    exit 0
}

# Check if help is requested
if [[ "$1" == "-h" ]]; then
    display_usage
    exit 0
fi

# Function to check installed tools
check_tools() {
    tools=("bsqli" "subfinder" "sublist3r" "gf" "anew" "uro" "waymore" "katana" "qsreplace" "httpx")

    echo "Checking required tools:"
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            echo "$tool is installed at $(which $tool)"
        else
            echo "$tool is NOT installed or not in the PATH"
        fi
    done
}

# Check if tool installation check is requested
if [[ "$1" == "-i" ]]; then
    check_tools
    exit 0
fi

# single site scan functionality


if [[ "$1" == "-s" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,')

    mkdir -p bug_bounty_report/$domain_Without_Protocol/sqli/

    echo ""
    echo "=================================================================="
    echo "=============== Single site URLs getting ========================="
    echo "=================================================================="
    echo ""


    katana -u "$domain_Without_Protocol" -duc -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -aff -ef js,css -fs fqdn -o bug_bounty_report/$domain_Without_Protocol/sqli/singleSite_allurls_katana.txt 
    
    waymore -i "$domain_Without_Protocol" -n -mode U -oU bug_bounty_report/$domain_Without_Protocol/sqli/singleSite_allurls_waymore.txt
    echo""

    cat bug_bounty_report/$domain_Without_Protocol/sqli/singleSite_allurls_katana.txt bug_bounty_report/$domain_Without_Protocol/sqli/singleSite_allurls_waymore.txt | anew | tee bug_bounty_report/$domain_Without_Protocol/sqli/singleSite_Total_UniqueUrls.txt
    echo ""
    echo "Single Site Total Unique Urls:"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/singleSite_Total_UniqueUrls.txt | wc -l

    echo ""
    echo "=================================================================="
    echo "=============== Single site URLs getting finished ================"
    echo "=================================================================="
    echo ""


    echo ""
    echo "=================================================================="
    echo "=============== Single site parameters getting ==================="
    echo "=================================================================="
    echo ""

    
    
    cat bug_bounty_report/$domain_Without_Protocol/sqli/singleSite_Total_UniqueUrls.txt |  uro -f hasparams | gf sqli | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee bug_bounty_report/$domain_Without_Protocol/sqli/singleSite_Error_based_parameters.txt
    echo ""
    echo "Total Error based parameter are:"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/singleSite_Error_based_parameters.txt | wc -l
    echo ""


    cat bug_bounty_report/$domain_Without_Protocol/sqli/singleSite_Total_UniqueUrls.txt |  uro -f hasparams | gf sqli | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee bug_bounty_report/$domain_Without_Protocol/sqli/singleSite_Blind_based_parameters.txt
    echo ""
    echo "Total Blind based parameter are:"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/singleSite_Blind_based_parameters.txt | wc -l
    echo ""
    echo "=================================================================="
    echo "=========== Single site parameters getting finished =============="
    echo "=================================================================="
    echo ""

    echo ""
    echo "=================================================================="
    echo "============= Single site Blind SQLi getting ====================="
    echo "=================================================================="
    echo ""

    bsqli --urls bug_bounty_report/$domain_Without_Protocol/sqli/singleSite_Blind_based_parameters.txt -p payloads/sqli/xor.txt -t 5 -v -o bug_bounty_report/$domain_Without_Protocol/sqli/singleSite_Blind_based_SQLi_detected.txt
    echo ""
    echo "Total Blind based SQLi found:"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/singleSite_Blind_based_SQLi_detected.txt | wc -l

    echo ""
    echo "=================================================================="
    echo "============= Single site Blind SQLi finished ===================="
    echo "=================================================================="
    echo ""


    echo ""
    echo "=================================================================="
    echo "============= Single site Error SQLi getting ====================="
    echo "=================================================================="
    echo ""

    #esqli -l bug_bounty_report/$domain_Without_Protocol/sqli/singleSite_Error_based_parameters.txt -p payloads/sqli/errors.txt -t 10 -o bug_bounty_report/$domain_Without_Protocol/sqli/singleSite_Error_based_SQLi_detected.txt
    echo ""
    echo "Total Error based SQLi found:"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/singleSite_Error_based_SQLi_detected.txt | wc -l

    echo ""
    echo "=================================================================="
    echo "============= Single site Error SQLi finished ===================="
    echo "=================================================================="
    echo ""

    exit 0

fi


# single site scan functionality



# Multi site scan functionality


if [[ "$1" == "-m" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,')

    mkdir -p bug_bounty_report/$domain_Without_Protocol/sqli/

    echo ""
    echo "=================================================================="
    echo "=============== Multi site URLs getting ========================="
    echo "=================================================================="
    echo ""


    katana -u "$domain_Without_Protocol" -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -aff -ef js,css -o bug_bounty_report/$domain_Without_Protocol/sqli/multiSite_allurls_katana.txt 
    
    waymore -i "$domain_Without_Protocol" -mode U -oU bug_bounty_report/$domain_Without_Protocol/sqli/multiSite_allurls_waymore.txt
    echo""

    cat bug_bounty_report/$domain_Without_Protocol/sqli/multiSite_allurls_katana.txt bug_bounty_report/$domain_Without_Protocol/sqli/multiSite_allurls_waymore.txt | anew | tee bug_bounty_report/$domain_Without_Protocol/sqli/multiSite_Total_UniqueUrls.txt
    echo ""
    echo "Multi Site Total Unique Urls:"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/multiSite_Total_UniqueUrls.txt | wc -l

    echo ""
    echo "=================================================================="
    echo "=============== Multi site URLs getting finished ================"
    echo "=================================================================="
    echo ""


    echo ""
    echo "=================================================================="
    echo "=============== Multi site parameters getting ==================="
    echo "=================================================================="
    echo ""

    
    
    cat bug_bounty_report/$domain_Without_Protocol/sqli/multiSite_Total_UniqueUrls.txt |  uro -f hasparams | gf sqli | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee bug_bounty_report/$domain_Without_Protocol/sqli/multiSite_Error_based_parameters.txt
    echo ""
    echo "Total Error based parameter are:"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/multiSite_Error_based_parameters.txt | wc -l
    echo ""


    cat bug_bounty_report/$domain_Without_Protocol/sqli/multiSite_Total_UniqueUrls.txt |  uro -f hasparams | gf sqli | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee bug_bounty_report/$domain_Without_Protocol/sqli/multiSite_Blind_based_parameters.txt
    echo ""
    echo "Total Blind based parameter are:"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/multiSite_Blind_based_parameters.txt | wc -l
    echo ""
    echo "=================================================================="
    echo "=========== Multi site parameters getting finished =============="
    echo "=================================================================="
    echo ""

    echo ""
    echo "=================================================================="
    echo "============= Multi site Blind SQLi getting ====================="
    echo "=================================================================="
    echo ""

    bsqli --urls bug_bounty_report/$domain_Without_Protocol/sqli/multiSite_Blind_based_parameters.txt -p payloads/sqli/xor.txt -t 5 -v -o bug_bounty_report/$domain_Without_Protocol/sqli/multiSite_Blind_based_SQLi_detected.txt
    echo ""
    echo "Total Blind based SQLi found:"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/multiSite_Blind_based_SQLi_detected.txt | wc -l

    echo ""
    echo "=================================================================="
    echo "============= Multi site Blind SQLi finished ===================="
    echo "=================================================================="
    echo ""


    echo ""
    echo "=================================================================="
    echo "============= Multi site Error SQLi getting ====================="
    echo "=================================================================="
    echo ""

    #esqli -l bug_bounty_report/$domain_Without_Protocol/sqli/multiSite_Error_based_parameters.txt -p payloads/sqli/errors.txt -t 10 -o bug_bounty_report/$domain_Without_Protocol/sqli/multiSite_Error_based_SQLi_detected.txt
    echo ""
    echo "Total Error based SQLi found:"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/multiSite_Error_based_SQLi_detected.txt | wc -l

    echo ""
    echo "=================================================================="
    echo "============= Multi site Error SQLi finished ===================="
    echo "=================================================================="
    echo ""

    exit 0

fi


# multi site scan functionality

# subfinder, sublist3r


if [[ "$1" == "-ml" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,')

    mkdir -p bug_bounty_report/$domain_Without_Protocol/sqli/
    echo ""
    echo "=================================================================="
    echo "================== Subdomains collecting ========================="
    echo "=================================================================="
    echo ""

    subfinder -d "$domain_Without_Protocol" -recursive -all -o bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_subdomains_subfinder.txt

    sublist3r -d "$domain_Without_Protocol" -t 10 -o bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_subdomains_sublist3r.txt
    echo ""

    cat bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_subdomains_subfinder.txt bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_subdomains_sublist3r.txt | anew | tee bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_total_subdomains.txt
    echo ""
    echo "Multi level total subdomains are:"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_total_subdomains.txt | wc -l


    httpx -l bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_total_subdomains.txt -t 70 -mc 200 -o bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_alive_subdomains.txt
    
    # -mc 200,301,302,401,403,500
    cat bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_alive_subdomains.txt | sed -e 's~http://~~g' -e 's~https://~~g' -e 's~www\.~~g' | anew bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_alive_subdomains_forUrl.txt

    echo ""
    echo "Total alive subdomains are:"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_alive_subdomains.txt | wc -l
    echo ""
    echo "Total alive subdomains for finding urls are:"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_alive_subdomains_forUrl.txt | wc -l
    
    echo ""
    echo "=================================================================="
    echo "=============== Subdomains collecting finished ==================="
    echo "=================================================================="
    echo ""


    echo ""
    echo "=================================================================="
    echo "=================== Subdomains URLs collecting ==================="
    echo "=================================================================="
    echo ""

    katana -list bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_alive_subdomains_forUrl.txt -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -aff -ef js,css -fs fqdn -o bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_AllUrls_katana.txt


    cat bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_alive_subdomains_forUrl.txt | while read domain; do waymore -i "$domain" -n -mode U -oU bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_AllUrls_waymore.txt; done

    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_AllUrls_katana.txt bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_AllUrls_waymore.txt | anew bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_AllUnique_urls.txt
    echo "Total Urls are:"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_AllUnique_urls.txt | wc -l

    echo ""
    echo "=================================================================="
    echo "=============== Subdomains URLs collecting finished =============="
    echo "=================================================================="
    echo ""


    echo ""
    echo "=================================================================="
    echo "=============== Subdomain parameters collecting =================="
    echo "=================================================================="
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_AllUnique_urls.txt | sed '/%/d' | grep -v -E 'js|css' | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | uro -f hasparams | gf sqli | tee bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_Error_based_parameters.txt

    cat bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_AllUnique_urls.txt | sed '/%/d' | grep -v -E 'js|css' | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | uro -f hasparams | gf sqli | tee bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_Blind_based_parameters.txt
    echo ""


    echo ""
    echo "=================================================================="
    echo "=========== Subdomain parameters collecting finished ============="
    echo "=================================================================="
    echo ""



    echo ""
    echo "=================================================================="
    echo "============= Subdomains Blind SQLi getting ====================="
    echo "=================================================================="
    echo ""

    bsqli --urls bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_Blind_based_parameters.txt -p payloads/sqli/xor.txt -t 5 -v -o bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_Blind_based_sqli_detected.txt
    echo ""
    echo "Total Blind based SQLi found:"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_Blind_based_sqli_detected.txt | wc -l

    echo ""
    echo "=================================================================="
    echo "============== Subdomains Blind SQLi finished ===================="
    echo "=================================================================="
    echo ""


    echo ""
    echo "=================================================================="
    echo "============= Subdomains Error SQLi getting ====================="
    echo "=================================================================="
    echo ""

    #esqli -l bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_Error_based_parameters.txt -p payloads/sqli/errors.txt -t 10 -o bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_Error_based_sqli_detected.txt
    echo ""
    echo "Total Error based SQLi found:"
    cat bug_bounty_report/$domain_Without_Protocol/sqli/multi_level_Error_based_sqli_detected.txt | wc -l

    echo ""
    echo "=================================================================="
    echo "============= Subdomains Error SQLi finished ===================="
    echo "=================================================================="
    echo ""


    exit 0

fi

# subfinder, sublist3r
