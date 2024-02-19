#Download ClinVar data...
for url in $(cat data/url)
do
    bash scripts/download.sh $url data
done

#Create ClinVar database file
mkdir -p databases
for file in data/variant_summary_*
do
    date=$(echo $file | grep -oP 'variant_summary_\K\d{4}-\d{2}' | sed 's/-/_/g')
    database="databases/clinvar_${date}.db"
    touch "$database"
done 