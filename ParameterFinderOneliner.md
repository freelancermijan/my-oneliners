## Params with katana

```
katana -u "testphp.vulnweb.com" -duc -f qurl -rl 170 -timeout 5 -retry 2 -aff -d 5 -ef ttf,woff,svg,png,css -ps -pss waybackarchive,commoncrawl,alienvault | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u  | tee testphp.vulnweb.com.txt
```

## Parameter with value

```
waymore -i "testphp.vulnweb.com" -mode U | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee parameters.txt
```

## Parameter without value

```
waymore -i "testphp.vulnweb.com" -mode U | qsreplace "FUZZ" | sort -u | tee parameters.txt
```

### Paramspider

```
paramspider -d "testphp.vulnweb.com" -s | grep "http" | tee paramspider.txt
```

### subfinder, httpx, unfurl, paramspider

```
subfinder -d "vulnweb.com" | httpx | unfurl domains | while read domains; do paramspider -d "$domains" -s -p "" | grep "http" | tee -a param.txt; done
```

### Arjun

```
arjun -u "http://testphp.vulnweb.com" -t 10 --passive wayback,commoncrawl,otx -oT arjun.txt
```
