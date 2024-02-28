#!/usr/bin/env python3.8
# -*- coding: utf-8 -*-
import sys, os
import sqlite3
try:
    # Trying to load a newer version
    import pysqlite3
    if pysqlite3.sqlite_version_info > sqlite3.sqlite_version_info:
        del sqlite3
        import pysqlite3 as sqlite3
    else:
        del pysqlite3
except:
    pass

if sqlite3.sqlite_version_info < (3, 37, 0):
    raise AssertionError("Este programa necesita una versión de SQLite igual o superior a 3.37.0")

# For compressed input files
import gzip
import re

CLINVAR_TABLE_DEFS = [
    '''CREATE TABLE IF NOT EXISTS variants (
        allele_id INTEGER NOT NULL,
        variant_type TEXT NOT NULL,
        gene_id INTEGER,
        gene_symbol TEXT,
        clinical_significance TEXT,
        phenotype TEXT,
        reference_assembly TEXT,
        chromosome TEXT NOT NULL,
        chr_start INTEGER NOT NULL,
        chr_stop INTEGER NOT NULL,
        reference_allele TEXT,
        alternative_allele TEXT,
        variation_id INTEGER NOT NULL,
        variant_origin TEXT
    ) STRICT''',
    '''CREATE INDEX IF NOT EXISTS idx_variants_gene_id ON variants(gene_id)''',
    '''CREATE INDEX IF NOT EXISTS idx_variants_chromosome ON variants(chromosome, chr_start, chr_stop)'''
]

def open_clinvar_db(db_file):
    if not os.path.exists(db_file):
        db = sqlite3.connect(db_file, isolation_level=None)
        cur = db.cursor()
        try:
            cur.execute("PRAGMA journal_mode=WAL")
        except sqlite3.Error as e:
            print("An error occurred: {}".format(str(e)), file=sys.stderr)
        finally:
            cur.close()
        db.close()
    
    db = sqlite3.connect(db_file)
    cur = db.cursor()
    try:
        cur.execute("PRAGMA synchronous = normal;")
        cur.execute("PRAGMA FOREIGN_KEYS=ON")
        for tableDecl in CLINVAR_TABLE_DEFS:
            cur.execute(tableDecl)
    except sqlite3.Error as e:
        print("An error occurred: {}".format(str(e)), file=sys.stderr)
    finally:
        cur.close()
    return db

def store_clinvar_file(db, clinvar_file):
    with gzip.open(clinvar_file, "rt", encoding="utf-8") as cf:
        headerMapping = None
        cur = db.cursor()
        with db:
            for line in cf:
                wline = line.rstrip("\n")
                if (headerMapping is None) and (wline.startswith('#')):
                    wline = wline.lstrip("#")
                    columnNames = re.split(r"\t", wline)
                    headerMapping = {}
                    for columnId, columnName in enumerate(columnNames):
                        headerMapping[columnName] = columnId
                else:
                    columnValues = re.split(r"\t", wline)
                    for iCol, vCol in enumerate(columnValues):
                        if len(vCol) == 0 or vCol == "-":
                            columnValues[iCol] = None
                    allele_id = int(columnValues[headerMapping["AlleleID"]])
                    variant_type = columnValues[headerMapping["Type"]]
                    gene_id = columnValues[headerMapping["GeneID"]]
                    gene_symbol = columnValues[headerMapping["GeneSymbol"]]
                    clinical_significance = columnValues[headerMapping["ClinicalSignificance"]]
                    phenotype = columnValues[headerMapping["PhenotypeList"]]  
                    reference_assembly = columnValues[headerMapping["Assembly"]]
                    chromosome = columnValues[headerMapping["Chromosome"]]
                    chr_start = columnValues[headerMapping["Start"]]
                    chr_stop = columnValues[headerMapping["Stop"]]
                    reference_allele = columnValues[headerMapping["ReferenceAlleleVCF"]]
                    alternative_allele = columnValues[headerMapping["AlternateAlleleVCF"]]
                    variation_id = int(columnValues[headerMapping["VariationID"]])
                    variant_origin = columnValues[headerMapping["OriginSimple"]]
                    cur.execute("""
                        INSERT INTO variants(
                            allele_id, 
                            variant_type, 
                            gene_id, gene_symbol, 
                            clinical_significance, 
                            phenotype, 
                            reference_assembly, 
                            chromosome, 
                            chr_start, 
                            chr_stop, 
                            reference_allele, 
                            alternative_allele, 
                            variation_id, 
                            variant_origin) 
                        VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                    """, (allele_id, variant_type, gene_id, gene_symbol, clinical_significance, phenotype, reference_assembly, chromosome, chr_start, chr_stop, reference_allele, alternative_allele, variation_id, variant_origin))
        cur.close()

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: {0} {{database_file}} {{compressed_clinvar_file}}".format(sys.argv[0]), file=sys.stderr)
        sys.exit(1)
    db_file = sys.argv[1]
    clinvar_file = sys.argv[2]
    db = open_clinvar_db(db_file)
    try:
        store_clinvar_file(db, clinvar_file)
    finally:
        db.close()


