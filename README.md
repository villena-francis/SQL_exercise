# Practical assignment for "SQL databases" 2023-2024

# Purpose

This repository serves as a submission for the ***final project of the Programming and Management of SQL Databases course***, overseen by [@jmfernandez](https://github.com/jmfernandez) and [@eandresleon](https://github.com/eandresleon), within the Bioinformatics Master's program at ENS-ISCIII. 

The original assignment prompt can be accessed through this [link](https://drive.google.com/file/d/1-Sh3ucoHaoUjv3kEpWo5S-7XR5I_A66t/view).

# Contents

* [Assigments](#assigments)

* [Exploration and initial analysis of datasets](#exploration-and-initial-analysis-of-datasets)

* [Development of python programs for data importing](#development-of-python-programs-for-data-importing)

* [Interpretation of questions for SQLite queries design](#interpretation-of-questions-for-sqlite-queries-design)

* [THE PIPELINE TO SOLVE ALL ASSIGMENTS](#use-of-a-pipeline-to-solve-all-assigments)

# Assigments

## Part 1

We will generate SQL databases from the information stored up to December 2023 in the ClinVar and CIViC databases. To do this, we will need to develop Python programs that import variant statistics by gene and the sci-articles citations related to these variants.

## Part 2

The databases generated in the first part should be used to formulate SQLite queries that answer the following questions:

1. How many variants are related to the P53 gene using the GRCh38 assembly as a reference in ClinVar and in CIViC?

2. Which 'single nucleotide variant' is more frequent: a Guanine to Adenine substitution, or a Guanine to Thymine substitution? Use the annotations based on the GRCh37 assembly to quantify and provide the total counts for both ClinVar and CIViC.

3. What are the three genes in ClinVar with the highest number of insertions, deletions, or indels? Use the GRCh37 assembly to quantify and provide the total numbers.

4. What is the most common deletion in hereditary breast cancer in CIViC? And in ClinVar? Please include in your answer the reference genome, the number of occurrences, the reference allele, and the observed allele.

5. View the gene identifier and the coordinates of the ClinVar variants from the GRCh38 assembly related to the phenotype of Acute infantile liver failure due to synthesis defect of mtDNA-encoded proteins.

6. For those ClinVar variants with clinical significance 'Pathogenic' or 'Likely pathogenic', retrieve the coordinates, the reference allele, and the altered allele for hemoglobin (HBB) in the GRCh37 assembly.

7. Calculate the number of GRCh37 assembly variants located on chromosome 13, between the coordinates 10,000,000 and 20,000,000, for both ClinVar and CIViC.

8. Calculate the number of ClinVar variants for which clinical significance entries have been provided that are not 'Uncertain significance', from the GRCh38 assembly, in those variants related to BRCA2.

9. Retrieve the list of pubmed_ids from ClinVar associated with the GRCh38
assembly variants related to the phenotype of glioblastoma.

10. Obtain the number of variants on chromosome 1 and calculate the mutation frequency of this chromosome, for both GRCh37 and GRCh38. Is this frequency higher than that of chromosome 22? And what about when compared to the X chromosome? Use the chromosomal sizes available at https://www.ncbi.nlm.nih.gov/grc/human/data?asm=GRCh37.p13 and https://www.ncbi.nlm.nih.gov/grc/human/data?asm=GRCh38.p13 for the calculations.For this question, use only data provided by ClinVar.

# Exploration and initial analysis of datasets

The search for datasets focused on finding those that contained the necessary attributes to address the SQLite queries. To identify the attributes to import for the ClinVar case, the [documentation](https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/README) available in the [ClinVar tab-delimited files subdirectory](https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/) was consulted. The selected files were [var_citations.txt](https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/var_citations.txt) and [variant_summary_2023-12.txt.gz](https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/archive/variant_summary_2023-12.txt.gz)

The attributes chosen for the ClinVar queries were used as a reference to select [CIViC datasets](https://civicdb.org/releases/main) with corresponding attributes: [01-Dec-2023-VariantSummaries.tsv](https://civicdb.org/downloads/01-Dec-2023/01-Dec-2023-VariantSummaries.tsv) and [01-Dec-2023-ClinicalEvidenceSummaries.tsv](https://civicdb.org/downloads/01-Dec-2023/01-Dec-2023-ClinicalEvidenceSummaries.tsv). **Table 1** and **Table 2** list the chosen attributes by file and the standardized names assigned to them to facilitate the SQLite queries.

**Tabla 1.** Atributos sobre artículos científicos relacionados con las variantes
| var_citations      | ClinicalEvidenceSummaries | consensus name |
|--------------------|---------------------------|----------------|
| AlleleID           | molecular_profile_id      | allele_id      |
| citation_source    | source_type               | citation_source|
| citation_id        | citation_id               | citation_id    |

**Tabla 2.** Atributos de estadísticas de variantes por gen.
| variant_summary                     | VariantSummaries                     | consensus name        |
|-------------------------------------|--------------------------------------|-----------------------|
| AlleleID                            | single_variant_molecular_profile_id  | allele_id             |
| Type                                | variant_types                        | variant_type          |
| GeneID                              | entrez_id                            | gene_id               |
| GeneSymbol                          | gene                                 | gene_symbol           |
| ClinicalSignificance                | significance***                      | clinical_significance |
| PhenotypeList                       | disease***                           | phenotype             |
| Assembly                            | reference_build                      | reference_assembly    |
| Chromosome                          | chromosome                           | chromosome            |
| Start                               | start                                | chr_start             |
| Stop                                | stop                                 | chr_stop              |
| ReferenceAlleleVCF                  | reference_bases                      | reference_allele      |
| AlternateAlleleVCF                  | variant_bases                        | alternative_allele    |
| VariationID                         | vatiant_id                           | variant_id            |
| OriginSimple                        | variant_origin***                    | variant_origin        |

***___from ClinicalEvidenceSummaries___

# Development of python programs for data importing

The programs developed for this work derive from `clinvar_parser.py` that the instructors left as a reference. Said program generates tables in a 'database.db' file to import data from a compressed file 'dataset.txt.gz' using the following command:

```sh
python clinvar_parser.py database.db dataset.txt.gz
```
The following programs operate similarly, with minor variations:

`clinvar_a_parser.py` generates a 'citations' table for uploading ClinVar sci-articles citations related to variants from a non-compressed text file.

`clinvar_b_parser.py` generates a 'variants' table for uploading ClinVar statistics of variants by gene from a compressed text file.

`civic_c1_parser.py` generates a 'citations' table for uploading CIViC sci-articles citations related to variants (and some statistics of variants by gene) from a Tab-Separated Values file.

`civic_c2_parser.py` generates a 'variants' table for uploading CIViC statistics of variants by gene from a Tab-Separated Values file.

> All the programs are located in `/scripts`

# Interpretation of questions for SQLite queries design 

Below are some clarifications considered for this work due to the variable interpretation of some questions:

The set of variants  ***related to the P53 gene***  includes large deletions that affect several genes, including P53 among them. 

> If the request were for those variants only related to the P53 gene, the query would have been simpler using the clause `WHERE gene_id = 7157`

In ClinVar, there are some ***single nucleotide variants*** whose 'variant_type' does not contain that designation.

> This makes (in this case) the 'variant_type' attribute irrelevant, since to search for a specific single base change, G>A for example, it is sufficient to use `WHERE reference_allele = 'G' AND alternative_allele = 'A'`.

The question _What are the three genes in ClinVar with the highest ***number of insertions, deletions, or indels?***_ implies that one should query for the three genes with the highest number of events in any of those categories.

> That interpretation makes little sense from a scientific standpoint, so question 3 has been reinterpreted as _Which three genes in ClinVar have the highest number of insertions, the highest number of deletions, and the highest number of indels, respectively?_

CIViC does not explicitly mention the ***hereditary*** character of the pathologies associated with the variants.

> In this case, the alternative filter was `WHERE LOWER(variant_origin) LIKE '%germline%'`

There are various isoforms of ***hemoglobin***, and they are encoded by different genes: HBA1, HBA2, HBB...

> For question 6, it was considered that variants related exclusively to the HBB gene (β-hemoglobin) were requested. To capture variants that include additional genes and to exclude the HBB-LCR regulatory region (external to HBB) `WHERE gene_symbol LIKE '%HBB%' AND gene_symbol NOT LIKE '%HBB-LCR%'`

It is not clear if the specification ***variants between the coordinates 10,000,000 and 20,000,000*** refers to those whose start is within that interval, that begin and end within that interval, or that at least end within that interval.

> For this case, it has been considered that it refers to those whose start is within that interval `WHERE chr_start BETWEEN 10000000 AND 20000000;`

The complete queries to answer all the questions are stored in `scripts/questions.sh`

# THE PIPELINE TO SOLVE ALL ASSIGMENTS

The pipeline.sh was developed to automate the assignments for PART 1 and PART 2 (check them [here](#assigments)). To activate it, set the `SQL_exercise-main` folder from this repo as the working directory and use the following command:

``` sh
bash scripts/pipeline.sh
```
> To rerun `pipeline.sh` a second time, it's necessary to delete the previously generated content by executing `cleanup.sh` in the same manner.


**The script automates the following tasks:**

1. Call the `download.sh` script which retrieves the [selected files from ClinVar and CIViC](#exploration-and-initial-analysis-of-datasets) using their URLs (`data/url`) and generates their md5.

2. Generate the databases to which data from the downloaded ClinVar and CIViC files will be dumped. The names of these databases automatically include the date of the file versions used, in this case: `clinvar_2023_12.db` and `civic_01_Dec_2023.db`, stored in `/database`.

3. **PART 1**. Call the Python programs:

   * `clinvar_a_parser.py` generates the 'citations' table within `clinvar_2023_12.db` and loads content from a 'var_citations' file.

   * `clinvar_b_parser.py` generates the 'variants' table within `clinvar_2023_12.db` and loads content from a 'variant_summaries' file.

   * `civic_c1_parser.py` generates the 'citations' table within `civic_01_Dec_2023.db` and loads content from a 'ClinicalEvidenceSummaries' file.

   * `civic_c2_parser.py` generates the 'variants' table within `civic_01_Dec_2023.db` and loads content from a 'VariantSummaries' file.

4. **PART 2**. Call the `questions.sh` script, which executes SQLite queries on `clinvar_2023_12.db` and `civic_01_Dec_2023.db`, and generates an 'answers.txt' with the results.

**Once the pipeline has finished, your directory should look like this:**

```sh
.
├── data
│   ├── 01-Dec-2023-ClinicalEvidenceSummaries.tsv
│   ├── 01-Dec-2023-ClinicalEvidenceSummaries.tsv.md5
│   ├── 01-Dec-2023-VariantSummaries.tsv
│   ├── 01-Dec-2023-VariantSummaries.tsv.md5
│   ├── url
│   ├── var_citations.txt
│   ├── var_citations.txt.md5
│   ├── variant_summary_2023-12.txt.gz
│   └── variant_summary_2023-12.txt.gz.md5
├── database
│   ├── civic_01_Dec_2023.db
│   └── clinvar_2023_12.db
├── questions
│   ├── answers1.txt
│   └── answers.txt
└── scripts
    ├── civic_c1_parser.py
    ├── civic_c2_parser.py
    ├── cleanup.sh
    ├── clinvar_a_parser.py
    ├── clinvar_b_parser.py
    ├── clinvar_parser.py
    ├── download.sh
    ├── pipeline.sh
    └── questions.sh
```

