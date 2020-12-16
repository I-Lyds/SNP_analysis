#!/bin/bash

echo "The script starts now, vcftools may take a minute."

for f in *.vcf; do vcftools --vcf "$f" --minQ 20 --minDP 10 --recode --chr chr18 --from-bp 62393610 --to-bp 63301858 --out "$f".csv; done

echo "Formatting bed file."

for f in *.csv.recode.vcf; do grep -v '##' "$f" | awk '{print $1 "\t" $2 "\t" $2}' | awk '{if (NR!=1) {print}}' > "$f".bed; done

echo "Renaming your file!"

for file in *.samtools.vcf.csv.recode.vcf.bed; do mv -- "$file" "${file%%.samtools.vcf.csv.recode.vcf.bed}.bed" ; done

echo "Deleting unused output files."

find *.* -type f -name '*.csv.log' -exec rm f {} +

find *.* -type f -name '*.csv.recode.vcf' -exec rm f {} +

echo "Running intersectBed with Gene locations."

for f in ERR269492*.bed; do intersectBed -a genes.txt -b $f > "$f"_ovrlp.bed; done

echo "Done!"

for file in *.bed_ovrlp.bed; do mv -- "$file" "${file%%.bed_ovrlp.bed}.dog" ; done

echo "Counting the number of SNPs per gene"

for file in *.dog; do while read p; do grep $p "$file" | awk '{ sum += ($3-$2 +1)} END {print sum }' >> "$file".cat; done < names.txt; done

echo "Dividing by Gene Length!"

for f in *.dog.cat; do paste <(awk '{print $1}' "$f") <(awk '{print $1}' lengths.txt) | awk '{print $1 / $2}'  >"$f".leg; done

echo "Renaming your file!"

for file in *.dog.cat.leg; do mv -- "$file" "${file%%.dog.cat.leg}.col" ; done

echo "Adding column header."

#######for f in *.col; do f=$(ls -1tr *.col | head -1); echo $f | cat - $f > "$f".csv && rm $f; done
for f in *.col; do sed -i "1s/^/${f%.*}\n/" $f; done

###########for f in *.col.csv; do sed -i '1 s/....$//' "$f"; done
for f in *.col; do sed -i '1 s/....$//' "$f"; done

echo "Creating table."

#############for f in *.col.csv; do cat all_samples | paste - $f >temp; cp temp all_samples; done; rm temp
for f in *.col; do cat all_samples | paste - $f >temp; cp temp all_samples; done; rm temp

#####################paste <(awk '{print $1"\t"$2"\t"$3"\t"$4"\t"}' ) <(awk '{print $1}' names.txt )
