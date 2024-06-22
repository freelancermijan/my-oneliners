## Passive Subdomain Find

### Subfinder

```
subfinder -d vulnweb.com -all -recursive -o vulnweb.com.subfinder.txt
```

### Sublist3r

```
sublist3r -d "vulnweb.com" -t 20 -v -o vulnweb.com.sublist3r.txt
```

### Assetfinder

```
assetfinder -subs-only vulnweb.com | tee assetfinder.vulnweb.com.txt
```

### Subdominator

```
subdominator -d "vulnweb.com" -o vulnweb.com.subdominator.txt
```

#### Github-subdomains

```
github-subdomains -d vulnweb.com -t your_github_token -o github-subdomains.vulnweb.com.txt
```

## Active Subdomain Find

#### Dnsx

```
dnsx -d "vulnweb.com" -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -o vulnweb.com.dnsx.txt
```
