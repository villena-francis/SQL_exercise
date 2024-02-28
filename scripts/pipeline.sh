#Download ClinVar data...
for url in $(cat data/url)
do
    bash scripts/download.sh $url data
done

#Create ClinVar database file 
mkdir database

for variant_summary in data/variant_summary_*
do
    date=$(echo $variant_summary | grep -oP 'variant_summary_\K\d{4}-\d{2}' | sed 's/-/_/g')
    clinvar_db="database/clinvar_${date}.db"
    touch "$clinvar_db"
done

#EXERCISE A
var_citations="data/var_citations.txt"
python scripts/clinvar_a_parser.py $clinvar_db $var_citations

#EXERCISE B
python scripts/clinvar_b_parser.py $clinvar_db $variant_summary