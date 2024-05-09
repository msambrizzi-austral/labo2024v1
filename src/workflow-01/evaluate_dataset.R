# Cargar la biblioteca necesaria
library(data.table)

# Especificar la ruta del archivo
file_path <- "ruta/a/tu/archivo.gz"

# Abrir el archivo gz y leer el CSV
dataset <- fread(gzfile(file_path))