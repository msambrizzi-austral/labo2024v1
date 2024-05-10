# Cargar la biblioteca necesaria
library(data.table)
library(dplyr)
library(ggplot2)
library(lubridate)

setwd("~/buckets/b1")

# Define la ruta completa al archivo dentro del bucket mapeado
path_to_file <- "./datasets/competencia_2024.csv.gz"

# Leer el archivo .gz directamente y cargarlo en un data.table
dataset <- fread(cmd = paste("gunzip -c", path_to_file))

# Convertir 'foto_mes' a un formato de fecha
dataset <- dataset %>%
  mutate(fecha = ymd(paste0(foto_mes, "01")))  # Agrega '01' para convertirlo en una fecha completa

# Identificar los últimos dos meses y filtrarlos
# Ordenamos y obtenemos todas las fechas únicas
fechas_unicas <- unique(dataset$fecha)
# Ordenamos las fechas
fechas_ordenadas <- sort(fechas_unicas)

# Nos quedamos con todas las fechas excepto las dos últimas
fechas_a_considerar <- fechas_ordenadas[1:(length(fechas_ordenadas) - 2)]

# Filtrar el dataset para excluir los últimos dos meses
dataset_filtrado <- dataset %>% 
  filter(fecha %in% fechas_a_considerar)

# Agrupar por la fecha calculada y contar los casos de 'BAJA+2'
baja_por_fecha <- dataset_filtrado %>%
  group_by(fecha) %>%
  summarise(baja2_count = sum(clase_ternaria == "BAJA+2", na.rm = TRUE),
            total_clientes = n()) %>%
  mutate(proporcion_baja2 = baja2_count / (total_clientes + 2))

# Graficar la proporción de 'BAJA+2' por fecha
ggplot(baja_por_fecha, aes(x = fecha, y = proporcion_baja2)) +
  geom_line() +  # Línea para conectar los puntos
  geom_point() + # Puntos en cada dato
  labs(x = "Fecha", y = "Proporción de BAJA+2", title = "Proporción de BAJA+2 por Fecha") +
  theme_minimal()  # Estilo minimalista para el gráfico
