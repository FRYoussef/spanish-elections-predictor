# PASO 1 - Preparar el entorno

#
# 1.0.- Por si acaso: descargar las librerías usadas previamente
#
getwd()
setwd("C:/Users/laufu/Documents/Cuarto/Segundo cuatri/MIN/Proyecto/ElectionsPredictor-Complex_Networks")
rm(list=ls())

#Si fuera necesario, ejecuta la siguiente llamada para "salir al exterior"
#setInternet2(use = TRUE)

#
# 1.1.- Declaración de la función is.installed(x), que comprueba 
#       si un paquete ya está instalado.
#
is.installed <- function(mypkg) {
  is.element(mypkg, installed.packages()[,1]) 
}

#
# 1.2.- Instala (si no está instalada aún) la librería "twitteR",
#       necesaria para trabajar con Twitter, y la carga en memoria.
#
if (!is.installed("twitteR")){
  install.packages("twitteR")
}
library(twitteR)

#
# PASO 2 - Obtener la certificación de Twitter

#
# 2.1.- Preparar la llamada a la función setup_twitter_oauth()  
#       para autentificarse ante Twitter.
#

#
# 2.1.1.- Dar valor a la constante consumerKey con su valor correspondiente,
#         obtenido de la aplicación desarrollada en Twitter.
#
consumerKey <- "9wqUbq3u3ZgBq0ImLvTTuRbzr"


#
# 2.1.2.- Dar valor a la constante consumerSecret con su valor correspondiente,
#         obtenido de la aplicación desarrollada en Twitter.
#
consumerSecret <- "tbGNaYl7JiCHd2O0nGbu4dXZQGkcGgjnx0XSgT4QHShXejpjSD"

#
# 2.1.3.- Dar valor a la constante accessToken con su valor correspondiente,
#         obtenido de la aplicación desarrollada en Twitter.
#
accessToken <- "1095974486179004416-PFsOuHQ5XfVrw7ve3JSSqtDG3tUYoy"

#
# 2.1.4.- Dar valor a la constante accessSecret con su valor correspondiente,
#         obtenido de la aplicación desarrollada en Twitter.
#
accessSecret <- "hAg6VlYOzdibhtx3rLqdLYGk2SU7cJ4riuMRTdNE2wINX"

#
# 2.2.- Solicitar la autorización y las credenciales y
#       (opcionalmente) guardarla para futuros usos.
#
setup_twitter_oauth(consumerKey, consumerSecret, accessToken, accessSecret)

#
# Preguntará si se desea guardar en un fichero local las credenciales de acceso
# generadas por OAuth de forma que se faciliten y/u oculten en las siguientes
# sesiones de R:
#
# [1] "Using direct authentication"
# Use a local file to cache OAuth access credentials between R sessions?
# 1: Yes
# 2: No
#
# Si estás en un ordenador compartido, deberías responder que no (2); 
# en caso contrario, es más cómodo responder que sí (1).


