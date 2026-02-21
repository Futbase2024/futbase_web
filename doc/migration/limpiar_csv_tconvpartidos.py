#!/usr/bin/env python3
"""
Script para limpiar el archivo tconvpartidos.csv
Reemplaza valores 'NULL' literales por cadenas vacías en columnas numéricas
para que PostgreSQL pueda importarlos correctamente como NULL.
"""

import csv
import os

# Columnas que son de tipo numérico (DECIMAL) y pueden contener NULL
# Índices basados en 0
NUMERIC_COLUMNS = [
    22,  # posX
    23,  # posY
    26,  # posXCambio
    27,  # posYCambio
]

INPUT_FILE = 'tablas/tconvpartidos.csv'
OUTPUT_FILE = 'tablas/tconvpartidos_clean.csv'

def clean_csv():
    """Limpia el archivo CSV reemplazando NULL literales por cadenas vacías."""

    if not os.path.exists(INPUT_FILE):
        print(f"Error: No se encuentra el archivo {INPUT_FILE}")
        return

    rows_processed = 0
    nulls_replaced = 0

    with open(INPUT_FILE, 'r', encoding='utf-8', newline='') as infile, \
         open(OUTPUT_FILE, 'w', encoding='utf-8', newline='') as outfile:

        reader = csv.reader(infile)
        writer = csv.writer(outfile)

        # Copiar cabecera
        header = next(reader)
        writer.writerow(header)
        rows_processed += 1

        print(f"Cabecera: {len(header)} columnas")
        print(f"Columnas numéricas a limpiar: {[header[i] for i in NUMERIC_COLUMNS if i < len(header)]}")

        # Procesar filas
        for row in reader:
            rows_processed += 1

            # Limpiar columnas numéricas
            for col_idx in NUMERIC_COLUMNS:
                if col_idx < len(row):
                    if row[col_idx] == 'NULL' or row[col_idx].strip() == 'NULL':
                        row[col_idx] = ''  # Cadena vacía para NULL
                        nulls_replaced += 1

            writer.writerow(row)

            # Mostrar progreso cada 10000 filas
            if rows_processed % 10000 == 0:
                print(f"Procesadas {rows_processed} filas...")

    print(f"\n{'='*50}")
    print(f"Proceso completado:")
    print(f"  - Filas procesadas: {rows_processed}")
    print(f"  - Valores NULL reemplazados: {nulls_replaced}")
    print(f"  - Archivo de salida: {OUTPUT_FILE}")
    print(f"{'='*50}")

if __name__ == '__main__':
    clean_csv()
