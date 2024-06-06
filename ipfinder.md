### subfinder, subprober

```
subfinder -d "vulnweb.com" -recursive -all -silent | subprober -ip | sort -u | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | tee ips.txt
```


### subfinder, httpx

```
subfinder -d "vulnweb.com" -recursive -all -silent | httpx -silent -ip | grep "http" | awk '{print $2}' | tr -d '[]' | sort -u | tee ips.txt
```
