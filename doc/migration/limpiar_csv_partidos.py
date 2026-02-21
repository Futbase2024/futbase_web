#!/usr/bin/env python3
"""
Script para limpiar errores en el CSV de partidos:
1. Corregir comillas mal formateadas y caracteres especiales
2. Asegurar que cada fila tenga 55 campos
3. Limpiar valores NULL en columnas numéricas
4. Eliminar saltos de línea dentro de campos
"""
import csv
import io

# Archivos de entrada y salida
INPUT_FILE = '/Users/lokisoft1/Desktop/Desarrollo/WebFutbase3.0/doc/migration/tablas/tpartidos.csv'
OUTPUT_FILE = '/Users/lokisoft1/Desktop/Desarrollo/WebFutbase3.0/doc/migration/tablas/tpartidos_clean.csv'

# Número esperado de campos
EXPECTED_FIELDS = 55

# Columnas que son numéricas (índices basados en 0)
NUMERIC_COLUMNS = {
    0: 'id',
    1: 'idjornada',
    2: 'idtemporada',
    3: 'idcategoria',
    4: 'idequipo',
    5: 'idclub',
    6: 'idrival',
    9: 'idlugar',
    12: 'goles',
    13: 'golesrival',
    14: 'finalizado',
    15: 'primTiempo',
    16: 'descanso',
    17: 'directo',
    21: 'min',
    22: 'casafuera',
    23: 'veralineacion',
    24: 'verConvocatoria',
    43: 'visto',
    45: 'alrival',
    48: 'minutosporparte',
    49: 'numeropartes',
    54: 'crono_segundos_descanso',
}

# Columnas que son timestamp (índices basados en 0)
TIMESTAMP_COLUMNS = {
    10: 'fecha',
    49: 'updated_at',
    51: 'crono_timestamp_inicio',
    52: 'crono_timestamp_ultima_accion',
}

# Todas las columnas que necesitan limpieza de NULL
NULL_CLEAN_COLUMNS = NUMERIC_COLUMNS | TIMESTAMP_COLUMNS


def clean_field(value, index):
    """Limpia un campo individual."""
    if value is None:
        return ''

    # Convertir a string
    value = str(value)

    # Eliminar saltos de línea y reemplazar por espacio
    value = value.replace('\n', ' ').replace('\r', ' ')

    # Eliminar comillas dobles internas (que no sean de escape)
    # Si el valor empieza y termina con comillas, las mantenemos
    if value.startswith('"') and value.endswith('"') and len(value) > 1:
        # Quitar comillas externas, limpiar, y volver a poner
        inner = value[1:-1]
        # Eliminar comillas dobles internas
        inner = inner.replace('""', '"')  # Comillas escapadas -> una comilla
        inner = inner.replace('"', '')    # Comillas sueltas -> eliminar
        value = f'"{inner}"'
    else:
        # Eliminar comillas sueltas
        value = value.replace('"', '')

    # Reemplazar NULL/null por vacío en columnas numéricas y timestamp
    if index in NULL_CLEAN_COLUMNS:
        if value.strip().upper() == 'NULL':
            return ''

    return value


def preprocess_file(input_path):
    """
    Pre-procesa el archivo para:
    1. Normalizar comillas tipográficas a comillas estándar
    2. Detectar y unir líneas partidas de registros multilínea
    """
    with open(input_path, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()

    # Reemplazar comillas tipográficas por comillas estándar
    content = content.replace('"', '"').replace('"', '"')
    content = content.replace(''', "'").replace(''', "'")

    return content


def main():
    print(f"Leyendo: {INPUT_FILE}")

    # Pre-procesar el archivo
    content = preprocess_file(INPUT_FILE)

    # Usar io.StringIO para leer como archivo
    reader = csv.reader(io.StringIO(content))
    rows = list(reader)

    print(f"Total de filas leídas: {len(rows)}")

    # Extraer header
    header = rows[0]
    print(f"Columnas esperadas: {len(header)}")

    with open(OUTPUT_FILE, 'w', encoding='utf-8', newline='') as outfile:
        writer = csv.writer(outfile)

        # Escribir header
        writer.writerow(header)

        total_rows = 0
        fixed_nulls = 0
        fixed_multiline = 0
        errors = []

        for row_num, row in enumerate(rows[1:], start=2):
            try:
                # Verificar número de campos
                if len(row) < EXPECTED_FIELDS:
                    # Rellenar campos faltantes
                    while len(row) < EXPECTED_FIELDS:
                        row.append('')
                    errors.append(f"Línea {row_num}: solo {len(row)} campos, rellenados")
                elif len(row) > EXPECTED_FIELDS:
                    # Combinar campos extra (probablemente texto con comas)
                    extra = row[EXPECTED_FIELDS - 1:]
                    row = row[:EXPECTED_FIELDS - 1]
                    row.append(', '.join(extra))
                    errors.append(f"Línea {row_num}: {len(row)} campos, combinados")

                # Limpiar cada campo
                cleaned_row = []
                for i, value in enumerate(row):
                    if i in NULL_CLEAN_COLUMNS and str(value).strip().upper() == 'NULL':
                        cleaned_row.append('')
                        fixed_nulls += 1
                    else:
                        cleaned_row.append(clean_field(value, i))

                writer.writerow(cleaned_row)
                total_rows += 1

            except Exception as e:
                errors.append(f"Línea {row_num}: Error - {str(e)}")

    print(f"\nCompletado!")
    print(f"Filas procesadas: {total_rows}")
    print(f"Valores NULL limpiados: {fixed_nulls}")
    print(f"Archivo de salida: {OUTPUT_FILE}")

    if errors:
        print(f"\nAdvertencias/Errores ({len(errors)}):")
        for err in errors[:20]:
            print(f"  {err}")
        if len(errors) > 20:
            print(f"  ... y {len(errors) - 20} más")

    # Verificar el archivo de salida
    print("\nVerificando archivo de salida...")
    with open(OUTPUT_FILE, 'r', encoding='utf-8') as f:
        verify_reader = csv.reader(f)
        verify_rows = list(verify_reader)

    field_errors = 0
    for i, row in enumerate(verify_rows[1:], start=2):
        if len(row) != EXPECTED_FIELDS:
            if field_errors < 10:
                print(f"  Línea {i}: {len(row)} campos (esperados {EXPECTED_FIELDS})")
            field_errors += 1

    if field_errors == 0:
        print("  OK - Todas las filas tienen el número correcto de campos")
    else:
        print(f"  Total de líneas con campos incorrectos: {field_errors}")


if __name__ == '__main__':
    main()
