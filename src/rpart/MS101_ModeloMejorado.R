# Carga de librerías necesarias
library(mlr)
library(data.table)

# Carga del dataset
dataset <- fread("../datasets/dataset_pequeno.csv")

# Definición de tareas de entrenamiento y test
dtrain <- dataset[foto_mes == 202107] # Datos de entrenamiento
dapply <- dataset[foto_mes == 202109] # Datos de test

# Convertir dtrain a data.frame
dtrain <- as.data.frame(dtrain)

# Definición de la tarea para MLR
task <- makeClassifTask(data = dtrain, target = "clase_ternaria")

# Definición del modelo base
learner <- makeLearner("classif.rpart", predict.type = "prob")

# Definición del espacio de búsqueda de hiperparámetros como un objeto ParamSet
param_set <- makeParamSet(
    makeNumericParam("cp", lower = 0.01, upper = 0.5),
    makeIntegerParam("minsplit", lower = 10, upper = 50),
    makeIntegerParam("minbucket", lower = 5, upper = 20),
    makeIntegerParam("maxdepth", lower = 2, upper = 6)
)

# Definir valores para los bucles
cp_values <- seq(0.01, 0.5, by = 0.01)
minsplit_values <- c(10, 20, 40, 80, 160, 320, 640)
minbucket_values <- c(2, 4, 8, 16, 32, 64)
maxdepth_values <- c(4, 6, 8, 10, 12, 14)

# Vaciar el param_set
clearParamSet(param_set)

# Definir vectores internos
for (cp in cp_values) {
    for (minsplit in minsplit_values) {
        for (minbucket in minbucket_values) {
            for (maxdepth in maxdepth_values) {
                # Agregar combinación al param_set
                addParamSetMlr(param_set, list(
                    cp = cp,
                    minsplit = minsplit,
                    minbucket = minbucket,
                    maxdepth = maxdepth
                ))
            }
        }
    }
}


# Definición de la estrategia de validación cruzada
inner <- makeResampleDesc("CV", iters = 5)

# Definición del control de búsqueda
ctrl <- makeTuneControlGrid()

# Ejecución del grid search
grid_search <- tuneParams(
    learner = learner,
    task = task,
    resampling = inner,
    par.set = param_set,
    control = ctrl,
    measures = list(mlr::auc)
)

# Mejores hiperparámetros encontrados
best_params <- getTuneResult(grid_search)$best.parameters

# Construcción del modelo final con los mejores hiperparámetros
modelo_final <- train(learner = learner, task = task, subset = NULL,
                      control = list(cp = best_params$cp,
                                     minsplit = best_params$minsplit,
                                     minbucket = best_params$minbucket,
                                     maxdepth = best_params$maxdepth))

# Predicción con el modelo final
prediccion_final <- predict(modelo_final, newdata = dapply, type = "prob")

# Guardar predicciones en archivo CSV
dapply[, prob_baja2 := prediccion_final[, "BAJA+2"]]
dapply[, Predicted := as.numeric(prob_baja2 > 1 / 40)]
dir.create("./exp/")
dir.create("./exp/KA2001")
fwrite(dapply[, list(numero_de_cliente, Predicted)],
       file = "./exp/KA2001/K101_001.csv",
       sep = ",")
