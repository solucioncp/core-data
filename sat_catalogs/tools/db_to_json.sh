#!/bin/bash
DB=sat-catalogs.db
CSV_FILE="catalogos.csv"

wget -O sat-catalogs.db.bz2 https://github.com/phpcfdi/resources-sat-catalogs/releases/latest/download/catalogs.db.bz2
bunzip2 sat-catalogs.db.bz2


echo -n "Cargando lista de catálogos desde CSV ... "
# Leer la segunda columna del CSV (omitir la primera línea si es encabezado)
TABLES=($(cut -d',' -f2 "$CSV_FILE" | tail -n +2))
echo "OK"

for TABLE in "${TABLES[@]}"; do
    # Verificar si la tabla existe en la base de datos
    EXISTS=$(sqlite3 "$DB" "SELECT count(*) FROM sqlite_master WHERE type='table' AND name='$TABLE';")

    if [ "$EXISTS" -eq 1 ]; then
        echo -n "Exportando $TABLE ... "
        sqlite3 "$DB" ".mode json" "SELECT * FROM $TABLE;" | jq 'reduce .[] as $item ({}; .[$item.id] = $item.texto)' > "../$TABLE.json"
        echo "OK"
    else
        echo "La tabla $TABLE no existe en la base de datos, omitiendo..."
    fi
done

rm -f "$DB"
