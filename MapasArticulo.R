#!/usr/bin/env Rscript --vanilla
###############################################################################
# # Autor: John Fredy Valbuena L. 
# # Fecha: Marzo 25
# # Versión de R: 4.0.4
###############################################################################
rm(list = ls())
#Librerías a usar
library(cartography)
library(ggplot2) 
library(here)
library(ggspatial)
library(sf) 
# Establecer rutas de entrada y salida de datos y gráficos
rutas<-list(barrio=c(here("Datos/Barrios_Pop.shp")),
            vias=c(here("Datos/Vias.shp")),
            figuras=c(here("Gráficos/")));rutas
# Crear directorio para almacenar imágenes
dir.create("Gráficos", recursive = TRUE)

# Lectura de datos
pobla<-read_sf(rutas$barrio)
# Vías: Contexto para mapas
vias<-read_sf(rutas$vias)

# Reproyectar información a Datum Nacional CTM 12
CTM12<-"+proj=tmerc +lat_0=4.0 +lon_0=-73.0 +k=0.9992 +x_0=5000000 +y_0=2000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
pobla<-st_transform(pobla,st_crs(CTM12))
vias<-st_transform(vias,st_crs(CTM12))

# Centroides de polígonos
centro<-st_centroid(pobla)
y<-st_coordinates(centro) # Coordenadas de centroide
centro$lon<-y[,1]
centro$lat<-y[,2]
rm(y)


#              # 
 # Histograma #
  #          #
Barras<-ggplot(pobla, aes(reorder(Sector_Cat, -Pop_Tot), Pop_Tot))
Barras<-Barras + geom_bar(stat = "identity",fill="darksalmon")+coord_flip()+ 
  theme_grey()+
  ggtitle("Número de habitantes por sector catastral") + 
  xlab("Barrios") + ylab("N° habitantes")
  

# Guardar archivo
ggsave(filename = "Barras.jpeg",
       device = "jpeg",
       plot = Barras,
       width = 140,
       height = 140, 
       units = "mm", 
       dpi = 300,
       path = rutas$figuras)

#                           #
 # Mapa Cortes geométricos #
 #                       #

# Guardar
jpeg(filename = paste(rutas$figuras,"Coropletas por Cortes geométricos.jpeg",sep=""), 
     width = 180, height = 180,
     units = "mm", res = 300)


plot(st_geometry(vias),
     col = "grey40", 
     border = "grey",
     bg = "grey90", 
     lwd = .1,
     xlim = c(st_bbox(pobla)[c(1,3)]), 
     ylim = c(st_bbox(pobla)[c(2,4)]))

# Mapa temático población por barrio
choroLayer(
  x = pobla, 
  var = names(pobla)[3],
  method = "geom",
  nclass=5,
  col = carto.pal(pal1 = "orange.pal", n1 = 5),
  border = "black", 
  lwd = 0.5,
  legend.pos = "bottomright", 
  legend.title.txt = "Población total\n(Cortes geométricos)",
  add = TRUE
) 
# layout
layoutLayer(title = "Número de habitantes por sector catastral",
            sources = "Fuente: SISBEN (2016)",
            author = paste0("Elaboración propia\nDatum:CTM12\nLibrería R: cartography ", 
                            packageVersion("cartography")), 
            frame = FALSE, north = FALSE, tabtitle = TRUE)

north(pos = "topleft")

dev.off()

#                                  #  
# Mapa de símbolos proporcionales  #
#                                  #

# Guardar
jpeg(filename = paste(rutas$figuras,"Símbolos proporcionales.jpeg",sep=""), 
     width = 180, height = 180,
     units = "mm", res = 300)

# Mapa simbolos prporcionales
plot(st_geometry(pobla),
     border = "black",
     bg = "grey90", 
     lwd = 1,
     xlim = c(st_bbox(pobla)[c(1,3)]), 
     ylim = c(st_bbox(pobla)[c(2,4)]))

plot(st_geometry(vias),
     col = "grey40", 
     border = "grey",
     bg = "grey90", 
     lwd = .1,
     add = TRUE,
     xlim = c(st_bbox(pobla)[c(1,3)]), 
     ylim = c(st_bbox(pobla)[c(2,4)]))
# plot Símbolos proporcionales
propSymbolsLayer(
  x = pobla, 
  var = names(pobla)[3], 
  inches = 0.2, 
  symbols = "circle",
  col = "brown",
  legend.pos = "bottomright",  
  legend.title.txt = "Población total\n(Simbolos proporcionales)"
)
# Información de contexto
layoutLayer(title = "Número de habitantes por sector catastral",
            sources = "Fuente: SISBEN (2016)",
            author = paste0("Elaboración propia\nDatum:CTM12\nLibrería R: cartography ", 
                            packageVersion("cartography")),
            frame = FALSE, north = FALSE, tabtitle = TRUE)
# Flecha norte
north(pos = "topleft",south = FALSE)
dev.off()


#                                  #  
# Mapa Coropletas por quintiles    #
#         


# Guardar
jpeg(filename = paste(rutas$figuras,"Coropletas por Quintiles.jpeg",sep=""), width = 180, height = 180,
     units = "mm", res = 300)


plot(st_geometry(vias),
     col = "grey40", 
     border = "grey",
     bg = "grey90", 
     lwd = .1,
     xlim = c(st_bbox(pobla)[c(1,3)]), 
     ylim = c(st_bbox(pobla)[c(2,4)]))

# plot population density
choroLayer(
  x = pobla, 
  var = names(pobla)[3],
  method = "quantile",
  nclass=5,
  col = carto.pal(pal1 = "orange.pal", n1 = 5),
  border = "black", 
  lwd = 0.5,
  legend.pos = "bottomright", 
  legend.title.txt = "Población total\n(Clasificación por Quintiles)",
  add = TRUE
) 
# layout
layoutLayer(title = "Número de habitantes por sector catastral",
            sources = "Fuente: SISBEN (2016)",
            author = paste0("Elaboración propia\nDatum:CTM12\nLibrería R: cartography ", packageVersion("cartography")), 
            frame = FALSE, north = FALSE, tabtitle = TRUE)

north(pos = "topleft")

dev.off()
 
#                                      #  
 # Mapa Coropletas por Pretty-Breaks    #
 #                                     #

# Guardar
jpeg(filename = paste(rutas$figuras,"Coropletas por Quiebres de Pretty.jpeg",sep=""), width = 180, height = 180,
     units = "mm", res = 300)


plot(st_geometry(vias),
     col = "grey40", 
     border = "grey",
     bg = "grey90", 
     lwd = .1,
     xlim = c(st_bbox(pobla)[c(1,3)]), 
     ylim = c(st_bbox(pobla)[c(2,4)]))

# plot population density
choroLayer(
  x = pobla, 
  var = names(pobla)[3],
  method = "pretty",
  nclass=4,
  col = carto.pal(pal1 = "orange.pal", n1 = 4),
  border = "black", 
  lwd = 0.5,
  legend.pos = "bottomright", 
  legend.title.txt = "Población total\n(Quiebres de Pretty)",
  add = TRUE
) 
# layout
layoutLayer(title = "Número de habitantes por sector catastral",
            sources = "Fuente: SISBEN (2016)",
            author = paste0("Elaboración propia\nDatum:CTM12\nLibrería R: cartography ", packageVersion("cartography")), 
            frame = FALSE, north = FALSE, tabtitle = TRUE)

north(pos = "topleft")

dev.off()


