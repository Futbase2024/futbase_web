#!/usr/bin/env python3
"""
Script para limpiar valores NULL en columnas numéricas del CSV de jugadores.
"""
import csv
import sys

# Archivos de entrada y salida
INPUT_FILE = '/Users/lokisoft1/Desktop/Desarrollo/WebFutbase3.0/doc/migration/tablas/tjugadores.csv'
OUTPUT_FILE = '/Users/lokisoft1/Desktop/Desarrollo/WebFutbase3.0/doc/migration/tablas/tjugadores_clean.csv'

# Columnas que son numéricas (índices basados en 0)
# Basado en el header: id,idcategoria,idclub,idequipo,idposicion,idpiedominante,idestado,
# idtutor1,idtutor2,idtemporada,idprovincia,idlocalidad,...,activo,convocado,conventreno,
# peso,altura,...,codigoactivacion,idtipocuota,dorsal,...,recmedico,...,nota
NUMERIC_COLUMNS = {
    0: 'id',
    1: 'idcategoria',
    2: 'idclub',
    3: 'idequipo',
    4: 'idposicion',
    5: 'idpiedominante',
    6: 'idestado',
    7: 'idtutor1',
    8: 'idtutor2',
    9: 'idtemporada',
    10: 'idprovincia',
    11: 'idlocalidad',
    18: 'activo',
    19: 'convocado',
    20: 'conventreno',
    21: 'peso',
    22: 'altura',
    31: 'codigoactivacion',
    32: 'idtipocuota',
    33: 'dorsal',
    38: 'recmedico',
    40: 'nota',
}

def clean_row(row):
    """Limpia valores NULL en columnas numéricas."""
    cleaned = []
    for i, value in enumerate(row):
        if i in NUMERIC_COLUMNS:
            # Reemplazar NULL/null por vacío en columnas numéricas
            if value.strip().upper() == 'NULL':
                cleaned.append('')
            else:
                cleaned.append(value)
        else:
            cleaned.append(value)
    return cleaned

def main():
    print(f"Leyendo: {INPUT_FILE}")

    with open(INPUT_FILE, 'r', encoding='utf-8', errors='replace') as infile:
        reader = csv.reader(infile)
        header = next(reader)

        with open(OUTPUT_FILE, 'w', encoding='utf-8', newline='') as outfile:
            writer = csv.writer(outfile)
            writer.writerow(header)

            count = 0
            null_count = 0

            for row in reader:
                # Verificar si hay NULLs en columnas numéricas antes de limpiar
                for i, value in enumerate(row):
                    if i in NUMERIC_COLUMNS and value.strip().upper() == 'NULL':
                        null_count += 1

                cleaned_row = clean_row(row)
                writer.writerow(cleaned_row)
                count += 1

                if count % 1000 == 0:
                    print(f"Procesadas {count} filas...")

    print(f"\nCompletado!")
    print(f"Filas procesadas: {count}")
    print(f"Valores NULL limpiados: {null_count}")
    print(f"Archivo de salida: {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
