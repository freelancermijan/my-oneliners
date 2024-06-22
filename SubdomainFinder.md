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
assetfinder -subs-only vulnweb.com | tee vulnweb.com.assetfinder.txt
```

### Subdominator

```
subdominator -d "vulnweb.com" -o vulnweb.com.subdominator.txt
```

#### Github-subdomains

```
github-subdomains -d vulnweb.com -t your_github_token -o github-subdomains.vulnweb.com.txt
```

#### Amass

```
amass enum -passive -d "vulnweb.com" -o vulnweb.com.amass.txt
```

#### Knockpy

```
knockpy -d "vulnweb.com" --recon --save vulnweb.com
```

## Active Subdomain Find

#### Ffuf

```
ffuf -u "http://vulnweb.com" -H "Host: FUZZ.vulnweb.com" -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -c -of html -o vulnweb.com.ffuf.html
```

#### Dnsx

```
dnsx -d "vulnweb.com" -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt -o vulnweb.com.dnsx.txt
```
