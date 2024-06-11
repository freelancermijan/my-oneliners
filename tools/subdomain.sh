#!/usr/bin/env bash

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -s http://example.com"
    echo ""
    echo "Options:"
    echo "  -h               Display this help message"
    echo "  -s               Sort scan(sublist3r, assetfinder, subfinder)"
    echo "  -l               Long scan(sublist3r, subdominator)"
    echo ""
    echo "Required Tools:"
    echo "              https://github.com/tomnomnom/unfurl
              https://github.com/aboul3la/Sublist3r
              https://github.com/tomnomnom/assetfinder
              https://github.com/projectdiscovery/subfinder
              https://github.com/RevoltSecurities/Subdominator
              https://github.com/projectdiscovery/httpx
              https://github.com/projectdiscovery/nuclei
              https://github.com/haccer/subjack
              https://github.com/nmap/nmap
              https://github.com/projectdiscovery/naabu"
    exit 0
}

if [[ "$1" == "-h" ]]; then
    display_usage
    exit 0
fi

if [[ "$1" == "-s" ]]; then
    domain_Without_Protocol_save=$(echo "$2" | unfurl -u apexes)
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,;')

    mkdir -p bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/screenshot bug_bounty_report/$domain_Without_Protocol_save/recon/network

    echo ""
    echo "=================================================================="
    echo "================= Sublist3r checking ============================="
    echo "=================================================================="
    echo ""
    sublist3r -d "$domain_Without_Protocol" -t 20 -o bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/sublist3r.txt
    echo ""
    echo "=================================================================="
    echo "================= Sublist3r finished ============================="
    echo "=================================================================="
    echo ""


    echo ""
    echo "=================================================================="
    echo "================== Assetfinder checking =========================="
    echo "=================================================================="
    echo ""
    assetfinder "$domain_Without_Protocol" | tee bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/assetfinder.txt
    echo ""
    echo "=================================================================="
    echo "================== Assetfinder Finished =========================="
    echo "=================================================================="
    echo ""


    echo ""
    echo "=================================================================="
    echo "================== Subfinder checking ============================"
    echo "=================================================================="
    echo ""
    subfinder -d "$domain_Without_Protocol" -recursive -all -o bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/subfinder.txt
    echo ""
    echo "=================================================================="
    echo "================== Subfinder finished ============================"
    echo "=================================================================="
    echo ""


    cat bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/sublist3r.txt bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/assetfinder.txt bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/subfinder.txt | sort -u | tee bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/unique_Subdomains.txt
    cat bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/unique_Subdomains.txt | wc -l
    echo ""
    echo "=================================================================="
    echo "==================== All domain collection Finished =============="
    echo "=================================================================="
    echo ""


    echo ""
    echo "=================================================================="
    echo "================ Alive subdomains checking ======================="
    echo "=================================================================="
    echo ""

    httpx -l bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/unique_Subdomains.txt -sc -title -server -ip -td -t 160 -random-agent -o bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/httpx_full_detail_subdomains.txt

    echo ""
    echo "=================================================================="
    echo "================ Alive subdomains checking finished =============="
    echo "=================================================================="
    echo ""




    echo ""
    echo "=================================================================="
    echo "========================== IPs collecting ========================"
    echo "=================================================================="
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/httpx_full_detail_subdomains.txt | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort -u | tee bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/subdomain_ips.txt
    echo ""
    echo "=================================================================="
    echo "========================== IPs collecting finished ==============="
    echo "=================================================================="
    echo ""




    echo ""
    echo "=================================================================="
    echo "================== 200 subdomains checking ======================="
    echo "=================================================================="
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/httpx_full_detail_subdomains.txt | grep "200" | awk '{print $1}' | sort -u | tee bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/200_live_subdomains.txt

    echo ""
    echo "=================================================================="
    echo "================== 200 subdomains checking finished =============="
    echo "=================================================================="
    echo ""



    echo ""
    echo "=================================================================="
    echo "================== 200 subdomains screenshot taking =============="
    echo "=================================================================="
    echo ""
    httpx -l bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/200_live_subdomains.txt -mc 200 -system-chrome -ss -srd bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/screenshot -t 160 -random-agent

    echo ""
    echo "=================================================================="
    echo "============ 200 subdomains screenshot taking  finished =========="
    echo "=================================================================="
    echo ""

    # subdomains prepare for URLs finding

    cat bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/httpx_full_detail_subdomains.txt | grep "200" | awk '{print $1}' | sort -u | sed 's,http://,,;s,https://,,;s,www\.,,;' > bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/200_subdomains_for_url_finding.txt


    echo ""
    echo "=================================================================="
    echo "==================== Network Scanning ============================"
    echo "=================================================================="
    echo ""
    naabu -l bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/200_subdomains_for_url_finding.txt -passive -c 50 -nmap-cli '-sV' -o bug_bounty_report/$domain_Without_Protocol_save/recon/network/port_scanning.txt
    echo ""
    echo "=================================================================="
    echo "============== Network Scanning finished ========================="
    echo "=================================================================="
    echo ""


    echo ""
    echo "=================================================================="
    echo "======== Subjack 404 subdomain takeover checking ================="
    echo "=================================================================="
    echo ""
    # prepare for subdomain takeover

    cat bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/httpx_full_detail_subdomains.txt | grep "404" | awk '{print $1}' | sort -u > bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/404_subdomain_takeover.txt


    subjack -w bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/404_subdomain_takeover.txt -v -timeout 30 | tee bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/404_subdomain_takeover_final.txt

    echo ""
    echo "=================================================================="
    echo "============ Nuclei subdomain takeover checking =================="
    echo "=================================================================="
    echo ""
    nuclei -l bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/404_subdomain_takeover.txt -t ~/nuclei-templates/subdomain-takeover/detect-all-takeovers.yaml -duc -nh | tee -a bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/404_subdomain_takeover_final.txt
    echo ""
    echo "=================================================================="
    echo "============= 404 subdomain takeover finished ===================="
    echo "=================================================================="
    echo ""


    echo ""
    echo "=================================================================="
    echo "=========== 403 forbidden subdomains collecting =================="
    echo "=================================================================="
    echo ""

    cat bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/httpx_full_detail_subdomains.txt | grep "403" | awk '{print $1}' | sort -u | tee bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/403_Permission_need_subdomains.txt

    echo ""
    echo "=================================================================="
    echo "=========== 403 forbidden subdomains collecting finished ========="
    echo "=================================================================="
    echo ""


    cat bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/httpx_full_detail_subdomains.txt
    exit 0
    
fi


if [[ "$1" == "-l" ]]; then
    domain_Without_Protocol_save=$(echo "$2" | unfurl -u apexes)
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,;')

    mkdir -p bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/screenshot bug_bounty_report/$domain_Without_Protocol_save/recon/network

    echo ""
    echo "=================================================================="
    echo "================= Sublist3r checking ============================="
    echo "=================================================================="
    echo ""
    sublist3r -d "$domain_Without_Protocol" -t 20 -o bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/sublist3r_large.txt
    echo ""
    echo "=================================================================="
    echo "================= Sublist3r finished ============================="
    echo "=================================================================="
    echo ""


    echo ""
    echo "=================================================================="
    echo "================= Subdominator checking =========================="
    echo "=================================================================="
    echo ""
    subdominator -d "$domain_Without_Protocol" -cp ~/.config/Subdominator/provider-config.yaml -o bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/subdominator_large.txt
    echo ""
    echo "=================================================================="
    echo "============== Subdominator finished ============================="
    echo "=================================================================="
    echo ""


    cat bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/sublist3r_large.txt bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/subdominator_large.txt | sort -u | tee bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/unique_Subdomains_large.txt
    cat bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/unique_Subdomains_large.txt | wc -l
    echo ""
    echo "=================================================================="
    echo "==================== All domain collection Finished =============="
    echo "=================================================================="
    echo ""


    echo ""
    echo "=================================================================="
    echo "================ Alive subdomains checking ======================="
    echo "=================================================================="
    echo ""

    httpx -l bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/unique_Subdomains_large.txt -sc -title -server -ip -td -t 160 -random-agent -o bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/httpx_full_detail_subdomains_large.txt

    echo ""
    echo "=================================================================="
    echo "================ Alive subdomains checking finished =============="
    echo "=================================================================="
    echo ""

    echo ""
    echo "=================================================================="
    echo "================== 200 subdomains checking ======================="
    echo "=================================================================="
    echo ""
    cat bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/httpx_full_detail_subdomains_large.txt | grep "200" | awk '{print $1}' | sort -u | tee bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/200_live_subdomains_large.txt

    echo ""
    echo "=================================================================="
    echo "================== 200 subdomains checking finished =============="
    echo "=================================================================="
    echo ""



    echo ""
    echo "=================================================================="
    echo "================== 200 subdomains screenshot taking =============="
    echo "=================================================================="
    echo ""
    httpx -l bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/200_live_subdomains_large.txt -mc 200 -system-chrome -ss -srd bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/screenshot -t 160 -random-agent

    echo ""
    echo "=================================================================="
    echo "============ 200 subdomains screenshot taking  finished =========="
    echo "=================================================================="
    echo ""

    # subdomains prepare for URLs finding

    cat bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/httpx_full_detail_subdomains_large.txt | grep "200" | awk '{print $1}' | sort -u | sed 's,http://,,;s,https://,,;s,www\.,,;' > bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/200_subdomains_for_url_finding_large.txt

    echo ""
    echo "=================================================================="
    echo "==================== Network Scanning ============================"
    echo "=================================================================="
    echo ""
    naabu -l bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/200_subdomains_for_url_finding_large.txt -passive -c 50 -nmap-cli '-sV' -o bug_bounty_report/$domain_Without_Protocol_save/recon/network/port_scanning_large.txt
    echo ""
    echo "=================================================================="
    echo "============== Network Scanning finished ========================="
    echo "=================================================================="
    echo ""



    echo ""
    echo "=================================================================="
    echo "============= 404 subdomain takeover checking ===================="
    echo "=================================================================="
    echo ""
    # prepare for subdomain takeover

    cat bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/httpx_full_detail_subdomains_large.txt | grep "404" | awk '{print $1}' | sort -u > bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/404_subdomain_takeover_large.txt


    subjack -w bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/404_subdomain_takeover_large.txt -v -timeout 30 | tee bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/404_subdomain_takeover_final_large.txt

    echo ""
    echo "=================================================================="
    echo "============= 404 subdomain takeover finished ===================="
    echo "=================================================================="
    echo ""


    echo ""
    echo "=================================================================="
    echo "============ Nuclei subdomain takeover checking =================="
    echo "=================================================================="
    echo ""
    nuclei -l bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/404_subdomain_takeover_large.txt -t ~/nuclei-templates/subdomain-takeover/detect-all-takeovers.yaml -duc -nh | tee -a bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/404_subdomain_takeover_final_large.txt
    echo ""
    echo "=================================================================="
    echo "============ Nuclei subdomain takeover finished =================="
    echo "=================================================================="
    echo ""



    echo ""
    echo "=================================================================="
    echo "=========== 403 forbidden subdomains collecting =================="
    echo "=================================================================="
    echo ""

    cat bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/httpx_full_detail_subdomains_large.txt | grep "403" | awk '{print $1}' | sort -u | tee bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/403_Permission_need_subdomains_large.txt

    echo ""
    echo "=================================================================="
    echo "=========== 403 forbidden subdomains collecting finished ========="
    echo "=================================================================="
    echo ""

    cat bug_bounty_report/$domain_Without_Protocol_save/recon/subdomains/httpx_full_detail_subdomains_large.txt
    exit 0

fi
