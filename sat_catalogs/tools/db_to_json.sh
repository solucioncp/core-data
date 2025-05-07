#!/bin/bash
DB=sat-catalogs.db
JSON_MAPPING="catalogos.json"  # Archivo con el mapeo de nombres

wget -O sat-catalogs.db.bz2 https://github.com/phpcfdi/resources-sat-catalogs/releases/latest/download/catalogs.db.bz2
bunzip2 sat-catalogs.db.bz2

echo "Cargando mapeo de tablas desde JSON..."
# Leer el JSON y extraer los pares clave-valor
while IFS="=" read -r filename tablename; do
    echo -n "Exportando tabla '$tablename' a '$filename.json'... "

    # Verificar si la tabla existe
    EXISTS=$(sqlite3 "$DB" "SELECT count(*) FROM sqlite_master WHERE type='table' AND name='$tablename';")

    if [ "$EXISTS" -eq 1 ]; then
        sqlite3 "$DB" ".mode json" "SELECT * FROM $tablename;" | \
        jq 'reduce .[] as $item ({}; .[$item.id] = $item.texto)' > "../$filename.json"
        echo "OK"
    else
        echo "ERROR: La tabla '$tablename' no existe"
    fi
done < <(jq -r 'to_entries[] | "\(.key)=\(.value)"' "$JSON_MAPPING")

rm "$DB"
