### subfinder, httpx

```
subfinder -d "vulnweb.com" -recursive -all -silent | httpx -silent -ip | grep "http" | awk '{print $2}' | tr -d '[]' | tee ips.txt
```
