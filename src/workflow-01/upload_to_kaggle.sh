#!/bin/bash

# Directorio donde se encuentran los archivos CSV
DIRECTORY="./KA4310"

# Nombre de la competencia en Kaggle
COMPETITION="labo-i-2024-virtual"

# Cambiar al directorio
cd $DIRECTORY

# Encontrar todos los archivos CSV y subirlos a la competencia especificada
for file in *.csv; do
    echo "Subiendo $file a la competencia $COMPETITION en Kaggle..."
    kaggle competitions submit -c $COMPETITION -f "$file" -m "Submitting $file"
done

echo "Todos los archivos han sido subidos."

