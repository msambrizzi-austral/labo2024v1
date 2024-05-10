# Cargar la biblioteca necesaria
library(data.table)
library(dplyr)
library(ggplot2)
library(lubridate)
library(scales) 

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


# Crear el gráfico base
p <- ggplot(baja_por_fecha, aes(x = fecha, y = proporcion_baja2)) +
  geom_line(color = 'deepskyblue4', size = 1) +  # Línea para conectar los puntos
  geom_point(color = 'deepskyblue', size = 2) + # Puntos en cada dato
  labs(x = "Fecha", y = "Proporción de BAJA+2 por Mes", title = "BAJA+2/QClientes en T+2") +
  theme_minimal() +  # Estilo minimalista para el gráfico
  theme(plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 12),
        axis.text.x = element_text(angle = 90, hjust = 1, size = 9),
        axis.text.y = element_text(size = 9),
        legend.position = "bottom") +
  scale_x_date(labels = date_format("%Y-%m"), breaks = date_breaks("2 months"))  # Cada 2 meses

# Añadir los dos geom_rect con la estética fill mapeada para la leyenda
p <- p + geom_rect(aes(xmin = as.Date("2020-03-01"), xmax = as.Date("2020-04-30"), ymin = -Inf, ymax = Inf,
                       fill = "ASPO"), alpha = 0.03)

p <- p + geom_rect(aes(xmin = as.Date("2020-05-01"), xmax = as.Date("2021-02-28"), ymin = -Inf, ymax = Inf,
                       fill = "DISPO"), alpha = 0.03)

# Configurar la leyenda con scale_fill_manual
p <- p + scale_fill_manual("Descripción de Periodos",
                           values = c("ASPO" = 'deepskyblue', 
                                      "DISPO" = 'deepskyblue4'))
# Ajustar la leyenda para que refleje la transparencia
p <- p + guides(fill = guide_legend(override.aes = list(alpha = 0.6)))

# Mostrar el gráfico
print(p)

