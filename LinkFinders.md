# Single Domain URLs Finding

### Waymore

```
waymore -i "testphp.vulnweb.com" -n -mode U | tee testphp.vulnweb.com.txt
```

### waybackurls

```
waybackurls -no-subs testphp.vulnweb.com
```

### Gau

```
gau testphp.vulnweb.com --providers wayback,commoncrawl,otx,urlscan --threads 70 | tee urls.txt
```

### Katana

```
katana -u testphp.vulnweb.com -fs fqdn -rl 170 -timeout 5 -retry 2 -aff -d 5 -ef ttf,woff,svg,png,css -ps -pss waybackarchive,commoncrawl,alienvault -silent -o urls.txt
```

# Multi Domain URLs find

### Waymore

```
waymore -i "vulnweb.com" -mode U | tee vulnweb.com.txt
```

### Waybackurls

```
waybackurls vulnweb.com | tee vulnweb.com.txt
````

### Gau

```
gau --subs vulnweb.com --providers wayback,commoncrawl,otx,urlscan --threads 70 | tee urls.txt
```

### Katana

```
katana -u vulnweb.com -rl 170 -timeout 5 -retry 2 -aff -d 5 -ef ttf,woff,svg,png,css -ps -pss waybackarchive,commoncrawl,alienvault -silent -o urls.txt
```

# Subdomain list URLs finding

```
cat $allurls | while read subdomains; do waybackurls -no-subs "$subdomains" | tee -a bug_bounty_report/$domain_Without_Protocol/recon/links/waybackurls-mass.txt; done

cat $allurls | while read subdomains; do waymore -i "$subdomains" -n -mode U | tee -a bug_bounty_report/$domain_Without_Protocol/recon/links/waymore-mass.txt; done

cat $allurls | while read subdomains; do katana -u "$subdomains" -fs fqdn -rl 170 -timeout 5 -retry 2 -aff -d 4 -ef ttf,woff,svg,png,css -ps -pss waybackarchive,commoncrawl,alienvault -silent -o bug_bounty_report/$domain_Without_Protocol/recon/links/katana-mass.txt; done
```
