#!/usr/bin/env python3
"""
Script para limpiar valores NULL en columnas numéricas del CSV de ropa.
"""
import csv

# Archivos de entrada y salida
INPUT_FILE = '/Users/lokisoft1/Desktop/Desarrollo/WebFutbase3.0/doc/migration/tablas/tropa.csv'
OUTPUT_FILE = '/Users/lokisoft1/Desktop/Desarrollo/WebFutbase3.0/doc/migration/tablas/tropa_clean.csv'

# Columnas que son numéricas (índices basados en 0)
# Header: id,idjugador,idtemporada,idclub,idprenda,pvp,descuento,acuenta,entregado,nombre,tipopago,talla,fecha,fechaentrega,avisado,devuelto,fechadevolucion
NUMERIC_COLUMNS = {
    0: 'id',
    1: 'idjugador',
    2: 'idtemporada',
    3: 'idclub',
    4: 'idprenda',
    5: 'pvp',
    6: 'descuento',
    7: 'acuenta',
    8: 'entregado',
    10: 'tipopago',
    14: 'avisado',
    15: 'devuelto',
}

# Columnas que son timestamp (índices basados en 0)
TIMESTAMP_COLUMNS = {
    12: 'fecha',
    13: 'fechaentrega',
    16: 'fechadevolucion',
}

# Todas las columnas que necesitan limpieza de NULL
NULL_CLEAN_COLUMNS = NUMERIC_COLUMNS | TIMESTAMP_COLUMNS

def clean_row(row):
    """Limpia valores NULL en columnas numéricas y timestamp."""
    cleaned = []
    for i, value in enumerate(row):
        if i in NULL_CLEAN_COLUMNS:
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
                    if i in NULL_CLEAN_COLUMNS and value.strip().upper() == 'NULL':
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
