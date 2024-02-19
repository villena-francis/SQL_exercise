#Download ClinVar data...
for url in $(cat data/url)
do
    bash scripts/download.sh $url data
done