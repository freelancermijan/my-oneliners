

## Parameter with value

```
waymore -i "mmu.ac.uk" -mode U | qsreplace -a "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee parameters.txt
```

## Parameter without value

```
waymore -i "mmu.ac.uk" -mode U | qsreplace "FUZZ" | sort -u | tee parameters.txt
```

### Paramspider

```
paramspider -d "testphp.vulnweb.com" -s | grep "http" | tee paramspider.txt
```

### Arjun

```
arjun -u "http://testphp.vulnweb.com" -t 10 --passive wayback,commoncrawl,otx -oT arjun.txt
```
