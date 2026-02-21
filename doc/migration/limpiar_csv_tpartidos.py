#!/usr/bin/env python3
"""
Script para limpiar valores NULL en columnas numéricas del CSV de partidos.
"""
import csv

# Archivos de entrada y salida
INPUT_FILE = '/Users/lokisoft1/Desktop/Desarrollo/WebFutbase3.0/doc/migration/tablas/tpartidos_clean.csv'
OUTPUT_FILE = '/Users/lokisoft1/Desktop/Desarrollo/WebFutbase3.0/doc/migration/tablas/tpartidos_cleaned.csv'

# Columnas que son numéricas (índices basados en 0)
# Header: id,idjornada,idtemporada,idcategoria,idequipo,idclub,idrival,rival,escudorival,idlugar,fecha,goles,golesrival,finalizado,primTiempo,descanso,directo,minuto,hora,horaconvocatoria,min,casafuera,veralineacion,verConvocatoria,color1L,color2L,color3L,color5L,color4L,observaciones,obsconvocatoria,informe,infconvocatoria,dispositivo,arbitro,obsarbitro,cronica,previa,sistema,sistemafinal,camiseta,camisetapor,visto,obscoordinador,alrival,camisetarival,sistemarival,minutosporparte,numeropartes,updated_at,crono_estado,crono_timestamp_inicio,crono_timestamp_ultima_accion,crono_segundos_acumulados,crono_segundos_descanso
NUMERIC_COLUMNS = {
    0: 'id',
    1: 'idjornada',
    2: 'idtemporada',
    3: 'idcategoria',
    4: 'idequipo',
    5: 'idclub',
    6: 'idrival',
    9: 'idlugar',
    11: 'goles',
    12: 'golesrival',
    13: 'finalizado',
    14: 'primTiempo',
    15: 'descanso',
    16: 'directo',
    17: 'minuto',
    20: 'min',
    21: 'casafuera',
    22: 'veralineacion',
    23: 'verConvocatoria',
    39: 'visto',
    42: 'alrival',
    45: 'minutosporparte',
    46: 'numeropartes',
    51: 'crono_segundos_acumulados',
    52: 'crono_segundos_descanso',
}

# Columnas que son timestamp (índices basados en 0)
TIMESTAMP_COLUMNS = {
    10: 'fecha',
    47: 'updated_at',
    49: 'crono_timestamp_inicio',
    50: 'crono_timestamp_ultima_accion',
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
