#!/usr/bin/env python3.8
# -*- coding: utf-8 -*-

import sys, os
import sqlite3
import csv

# Función auxiliar para convertir a entero de forma segura
def safe_int(value, default=None):
    try:
        return int(value)
    except ValueError:
        return default

try:
    # Intentando cargar una versión más nueva
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

# Definiciones de la tabla ajustadas a los requisitos
CLINVAR_TABLE_DEFS = [
    '''CREATE TABLE IF NOT EXISTS variants (
        allele_id INTEGER NOT NULL,
        variant_type TEXT NOT NULL,
        gene_id INTEGER,
        gene_symbol TEXT,
        reference_assembly TEXT,
        chromosome TEXT NOT NULL,
        chr_start INTEGER,
        chr_stop INTEGER,
        reference_allele TEXT,
        alternative_allele TEXT,
        variant_id INTEGER NOT NULL
    ) STRICT''',
    '''CREATE INDEX IF NOT EXISTS idx_citations_allele_id ON citations(allele_id)''',
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
    with open(clinvar_file, "rt", encoding="utf-8") as cf:
        cur = db.cursor()
        tsv_reader = csv.DictReader(cf, delimiter="\t")
        with db:
            for row in tsv_reader:
                cur.execute("""
                    INSERT INTO variants(
                        allele_id, 
                        variant_type, 
                        gene_id, 
                        gene_symbol, 
                        reference_assembly, 
                        chromosome, 
                        chr_start, 
                        chr_stop, 
                        reference_allele, 
                        alternative_allele, 
                        variant_id)
                    VALUES(?,?,?,?,?,?,?,?,?,?,?)
                    """, (safe_int(row["single_variant_molecular_profile_id"]), row["variant_types"], safe_int(row["entrez_id"]), row["gene"],
                        row["reference_build"], row["chromosome"], safe_int(row["start"]), safe_int(row["stop"]),
                        row["reference_bases"], row["variant_bases"], safe_int(row["variant_id"])
                ))
        cur.close()

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: {0} {{database_file}} {{clinvar_file}}".format(sys.argv[0]), file=sys.stderr)
        sys.exit(1)
    db_file, clinvar_file = sys.argv[1], sys.argv[2]
    db = open_clinvar_db(db_file)
    try:
        store_clinvar_file(db, clinvar_file)
    finally:
        db.close()


