blue="\e[34m"
endblue="\e[0m"

echo -e "${blue}##############################################${endblue}"
echo -e "${blue}####### Starting SQL exercise pipeline #######${endblue}"

echo " "
echo " "

#Download data files...
echo -e "${blue}Downloading data files...${endblue}"

echo " "

for url in $(cat data/url)
do
    bash scripts/download.sh $url data
done

echo " "

#Create ClinVar database file
echo -e "${blue}Creating ClinVar database file...${endblue}"

mkdir -p database
shopt -s extglob
for variant_summary in data/variant_summary_!(*.md5)
do
    date=$(echo $variant_summary | grep -oP 'variant_summary_\K\d{4}-\d{2}' | sed 's/-/_/g')
    clinvar_db="database/clinvar_${date}.db"
    touch "$clinvar_db"
done

echo " "

#EXERCISE A
echo -e "${blue}Uploading ClinVar sci-articles citations related to variants...${endblue}"

var_citations="data/var_citations.txt"
python scripts/clinvar_a_parser.py $clinvar_db $var_citations

#EXERCISE B
echo -e "${blue}Uploading ClinVar statistics of variants by gene...${endblue}"

python scripts/clinvar_b_parser.py $clinvar_db $variant_summary

echo " "
echo " "

#Create CIViC database file
echo -e "${blue}Creating CIViC database file...${endblue}"

for VariantSummaries in data/*VariantSummaries!(*.md5)
do
    date=$(echo $VariantSummaries | grep -oP '\d{2}-[A-Za-z]{3}-\d{4}' | sed 's/-/_/g')
    civic_db="database/civic_${date}.db"
    touch "$civic_db"
done

echo " "

#EXERCISE C
echo -e "${blue}Uploading CIViC sci-articles citations related to variants...${endblue}"

EvidenceSummaries="data/*EvidenceSummaries*"
python scripts/civic_c1_parser.py $civic_db $EvidenceSummaries

echo -e "${blue}Uploading CIViC statistics of variants by gene...${endblue}"

python scripts/civic_c2_parser.py $civic_db $VariantSummaries

echo " "
echo " "

#QUESTIONS
echo -e "${blue}Resolving the proposed questions...${endblue}"

export clinvar_db
export civic_db
bash scripts/questions.sh

echo -e "${blue}'answers.txt' available in 'questions' folder${endblue}"

echo " "
echo " "

echo -e "${blue}######## SQL exercise pipeline ended #########${endblue}"
echo -e "${blue}##############################################${endblue}"
