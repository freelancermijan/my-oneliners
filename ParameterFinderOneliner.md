

## Parameter Finder Oneliner

```
waymore -i "mmu.ac.uk" -mode U | qsreplace "FUZZ" | grep "FUZZ" | sed 's/FUZZ//g' | sort -u | tee parameters.txt
```