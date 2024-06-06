### subfinder, subprober

```
subfinder -d "vulnweb.com" -recursive -all -silent | subprober -ip | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort -u | tee ips.txt
```

### subprober

```
shodanx custom -cq hostname:"vulnweb.com" -o ips.txt
```

### subfinder, httpx

```
subfinder -d "vulnweb.com" -recursive -all -silent | httpx -silent -ip | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort -u | tee ips.txt
```
