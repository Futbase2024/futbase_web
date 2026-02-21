#!/usr/bin/env python3
"""
Script para limpiar valores NULL en columnas numéricas del CSV de pagos personales.
"""
import csv

# Archivos de entrada y salida
INPUT_FILE = '/Users/lokisoft1/Desktop/Desarrollo/WebFutbase3.0/doc/migration/tablas/tpagopersonal.csv'
OUTPUT_FILE = '/Users/lokisoft1/Desktop/Desarrollo/WebFutbase3.0/doc/migration/tablas/tpagopersonal_clean.csv'

# Columnas que son numéricas (índices basados en 0)
# Header: id,idclub,idequipo,iduser,concepto,tipo,importe,fecha,idtemporada
NUMERIC_COLUMNS = {
    0: 'id',
    1: 'idclub',
    2: 'idequipo',
    3: 'iduser',
    6: 'importe',
    8: 'idtemporada',
}

def clean_row(row):
    """Limpia valores NULL en columnas numéricas."""
    cleaned = []
    for i, value in enumerate(row):
        if i in NUMERIC_COLUMNS:
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
                for i, value in enumerate(row):
                    if i in NUMERIC_COLUMNS and value.strip().upper() == 'NULL':
                        null_count += 1

                cleaned_row = clean_row(row)
                writer.writerow(cleaned_row)
                count += 1

    print(f"\nCompletado!")
    print(f"Filas procesadas: {count}")
    print(f"Valores NULL limpiados: {null_count}")
    print(f"Archivo de salida: {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
