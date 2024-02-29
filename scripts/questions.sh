mkdir -p questions
touch questions/answers.txt

{
echo "Databases utilized to solve the questions:"
echo "$clinvar_db"
echo "$civic_db"

echo "1. How many variants are related to the P53 gene using the GRCh38 assembly"
echo "as a reference in ClinVar and in CIViC?"

echo " "

clinvar1=$(sqlite3 $clinvar_db << EOF 
"SELECT COUNT(*)
FROM variants
WHERE gene_symbol
LIKE '%TP53%'
  AND reference_assembly = 'GRCh38';"
EOF
)

echo "ClinVar: $clinvar1"

echo " "

civic1=$(sqlite3 $civic_db << EOF
"SELECT COUNT(*)
FROM variants
WHERE gene_symbol
LIKE '%TP53%'
  AND reference_assembly = 'GRCh38';"
EOF
)

echo "CIViC: $civic1"

echo " "
echo " "

echo "2. Which 'single nucleotide variant' is more frequent: a Guanine to Adenine"
echo "substitution, or a Guanine to Thymine substitution? Use the annotations based"
echo "on the GRCh37 assembly to quantify and provide the total counts for both"
echo "ClinVar and CIViC."

echo " "

echo "ClinVar: "
sqlite3 $clinvar_db << EOF
.mode markdown
SELECT 'G>A' AS change,
COUNT(*) AS freq
FROM variants
WHERE variant_type = 'single nucleotide variant'
  AND reference_assembly = 'GRCh37'
  AND reference_allele = 'G'
  AND alternative_allele = 'A'
UNION ALL
SELECT 'G>T' AS change,
COUNT(*) AS freq 
FROM variants 
WHERE variant_type = 'single nucleotide variant'
  AND reference_assembly = 'GRCh37'
  AND reference_allele = 'G'
  AND alternative_allele = 'T';
EOF

echo " "

echo "CIViC:"
sqlite3 $civic_db << EOF
.mode markdown 
SELECT 'G>A' AS change, 
COUNT(*) AS freq 
FROM variants 
WHERE reference_assembly = 'GRCh37' 
  AND reference_allele = 'G' 
  AND alternative_allele = 'A' 
UNION ALL 
SELECT 'G>T' AS change, 
COUNT(*) AS freq 
FROM variants 
WHERE reference_assembly = 'GRCh37' 
  AND reference_allele = 'G' 
  AND alternative_allele = 'T';
EOF

echo " "
echo " "

echo "3. What are the three genes in ClinVar with the highest number of"
echo "insertions, deletions, or indels? Use the GRCh37 assembly to quantify and"
echo "provide the total numbers."

echo " "

echo "ClinVar:"
sqlite3 $clinvar_db << EOF
.mode markdown 
SELECT gene_symbol, 
COUNT(*) AS total 
FROM variants 
WHERE (variant_type = 'Insertion' 
  OR variant_type = 'Deletion' 
  OR variant_type = 'Indel') 
  AND reference_assembly = 'GRCh37' 
GROUP BY gene_symbol 
ORDER BY total DESC 
LIMIT 3;
EOF

echo " "
echo " "

echo "4. What is the most common deletion in hereditary breast cancer in CIViC?"
echo "And in ClinVar? Please include in your answer the reference genome, the number"
echo "of occurrences, the reference allele, and the observed allele."

echo " "

echo "CIViC:"
civic5=$(sqlite3 $civic_db << EOF
.mode markdown 
SELECT v.variant_type,
       v.reference_assembly,
       v.gene_symbol,
       COUNT(*) AS occurrence,
       v.reference_allele,
       v.alternative_allele
FROM variants v
JOIN citations c ON v.allele_id = c.allele_id
WHERE LOWER(c.phenotype) LIKE '%breast%' 
  AND LOWER(c.phenotype) LIKE '%cancer%' 
  AND LOWER(c.variant_origin) LIKE '%germline%' 
  AND LOWER(v.variant_type) LIKE '%deletion%'
GROUP BY v.variant_type, 
         v.reference_assembly, 
         v.gene_symbol, 
         v.reference_allele, 
         v.alternative_allele
ORDER BY 
  occurrence DESC
LIMIT 1;
EOF
)

if [ -z "$output" ]; then
    echo "No results found for your search criteria"
else
    echo "$output"
fi

echo " "

echo "ClinVar:"
sqlite3 $clinvar_db << EOF
.mode markdown 
SELECT reference_assembly, 
       gene_symbol,
       variant_type,
       reference_allele, 
       alternative_allele, 
COUNT(*) AS occurrences 
FROM variants 
WHERE LOWER(phenotype) LIKE '%hereditary%' 
  AND LOWER(phenotype) LIKE '%breast%' 
  AND LOWER(phenotype) LIKE '%cancer%' 
  AND variant_type LIKE '%Deletion%'
  AND reference_assembly IN ('GRCh37', 'GRCh38')
  AND reference_allele != 'na'
GROUP BY reference_assembly, 
         gene_symbol,
         variant_type,
         reference_allele, 
         alternative_allele 
ORDER BY occurrences DESC 
LIMIT 1;
EOF

echo " "
echo " "

echo "5. View the gene identifier and the coordinates of the ClinVar variants from"
echo "the GRCh38 assembly related to the phenotype of Acute infantile liver failure"
echo "due to synthesis defect of mtDNA-encoded proteins."

echo " "

echo "ClinVar:"
sqlite3 $clinvar_db << EOF
.mode markdown 
SELECT gene_id, 
        chromosome, 
        chr_start, 
        chr_stop 
FROM variants 
WHERE reference_assembly = 'GRCh38' 
  AND phenotype LIKE '%Acute infantile liver failure due to synthesis defect of mtDNA-encoded proteins%';
EOF

echo " "
echo " "

echo "6. For those ClinVar variants with clinical significance 'Pathogenic' or"
echo "'Likely pathogenic', retrieve the coordinates, the reference allele, and the"
echo "altered allele for hemoglobin (HBB) in the GRCh37 assembly."

echo " "

echo "ClinVar:"
sqlite3 $clinvar_db << EOF
.mode markdown 
SELECT chromosome, 
        chr_start, 
        chr_stop, 
        reference_allele, 
        alternative_allele 
FROM variants
WHERE (clinical_significance = 'Pathogenic' 
  OR clinical_significance = 'Likely pathogenic') 
  AND gene_symbol LIKE '%HBB%' 
  AND gene_symbol NOT LIKE '%HBB-LCR%' 
  AND reference_assembly = 'GRCh37';
EOF

echo " "
echo " "

echo "7. Calculate the number of GRCh37 assembly variants located on chromosome 13,"
echo "between the coordinates 10,000,000 and 20,000,000, for both ClinVar and CIViC."

echo " "

echo "ClinVar:"
sqlite3 $clinvar_db << EOF
.mode markdown 
SELECT COUNT(*) AS number_of_variants 
FROM variants 
WHERE reference_assembly = 'GRCh37' 
  AND chromosome = '13'
  AND chr_start >= 10000000 
  AND chr_start <= 20000000;
EOF

echo " "

echo "CIViC:"
sqlite3 $civic_db << EOF
.mode markdown 
SELECT COUNT(*) AS number_of_variants 
FROM variants 
WHERE reference_assembly = 'GRCh37' 
  AND chromosome = '13'
  AND chr_start >= 10000000 
  AND chr_start <= 20000000;
EOF

echo " "
echo " "

echo "8. Calculate the number of ClinVar variants for which clinical significance"
echo "entries have been provided that are not 'Uncertain significance', from the"
echo "GRCh38 assembly, in those variants related to BRCA2."

echo " "

echo "ClinVar:"
sqlite3 $clinvar_db << EOF
.mode markdown 
SELECT COUNT(*) AS number_of_variants
FROM variants 
WHERE clinical_significance NOT LIKE 'Uncertain significance'
  AND reference_assembly = 'GRCh38'
  AND gene_symbol LIKE '%BRCA2%';
EOF

echo " "
echo " "

echo "9. Retrieve the list of pubmed_ids from ClinVar associated with the GRCh38"
echo "assembly variants related to the phenotype of glioblastoma."

echo " "

echo "ClinVar:"
sqlite3 $clinvar_db << EOF
.mode markdown
SELECT c.citation_source,
        c.citation_id
FROM citations c
INNER JOIN variants v
ON c.allele_id = v.allele_id
WHERE v.reference_assembly = 'GRCh38'
  AND v.phenotype LIKE '%glioblastoma%';
EOF

echo " "
echo " "

echo "10. Obtain the number of variants on chromosome 1 and calculate the mutation"
echo "frequency of this chromosome, for both GRCh37 and GRCh38. Is this frequency higher"
echo "than that of chromosome 22? And what about when compared to the X chromosome?"
echo "Use the chromosomal sizes available at"
echo "https://www.ncbi.nlm.nih.gov/grc/human/data?asm=GRCh37.p13 and"
echo "https://www.ncbi.nlm.nih.gov/grc/human/data?asm=GRCh38.p13 for the calculations."
echo "For this question, use only data provided by ClinVar."

echo " "

echo "For GRCh37:"
sqlite3 $clinvar_db << EOF
.mode markdown
SELECT '1' AS chromosome,
COUNT(*) AS number_of_variants,
COUNT(*) * 1.0 / 249250621 AS mutation_frequency
FROM variants
WHERE chromosome = '1'
  AND reference_assembly = 'GRCh37'
GROUP BY chromosome
UNION ALL
SELECT '22' AS chromosome,
COUNT(*) AS number_of_variants,
COUNT(*) * 1.0 / 51304566 AS mutation_frequency
FROM variants
WHERE chromosome = '22'
  AND reference_assembly = 'GRCh37'
GROUP BY chromosome
UNION ALL
SELECT 'X' AS chromosome,
COUNT(*) AS number_of_variants,
COUNT(*) * 1.0 / 155270560 AS mutation_frequency
FROM variants
WHERE chromosome = 'X'
  AND reference_assembly = 'GRCh37'
GROUP BY chromosome;
EOF

echo " "

echo "For GRCh38:"
sqlite3 $clinvar_db << EOF
.mode markdown 
SELECT '1' AS chromosome, 
COUNT(*) AS number_of_variants, 
COUNT(*) * 1.0 / 248956422 AS mutation_frequency 
FROM variants 
WHERE chromosome = '1' 
  AND reference_assembly = 'GRCh38' 
GROUP BY chromosome 
UNION ALL 
SELECT '22' AS chromosome, 
COUNT(*) AS number_of_variants, 
COUNT(*) * 1.0 / 50818468 AS mutation_frequency 
FROM variants 
WHERE chromosome = '22' 
  AND reference_assembly = 'GRCh38' 
GROUP BY chromosome 
UNION ALL 
SELECT 'X' AS chromosome, 
COUNT(*) AS number_of_variants,
COUNT(*) * 1.0 / 156040895 AS mutation_frequency 
FROM variants 
WHERE chromosome = 'X' 
  AND reference_assembly = 'GRCh38' 
GROUP BY chromosome;
EOF

echo " "
echo " "

} >> questions/answers.txt