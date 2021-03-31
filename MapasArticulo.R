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
  

#                           #
 # Mapa suave variabilidad #
  #                       #
m1<-ggplot(pobla) +
  annotation_scale()+
  annotation_north_arrow(location = "tr", which_north = "true", 
                         pad_x = unit(0.05, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering) +
  geom_sf(data = vias,fill="gray20",color="black", alpha = 0.2)+
  geom_sf(data = pobla, aes(fill = Pop_Tot), alpha = 0.7, color =NA) +
  theme_gray()+
  scale_fill_gradient(low = "#ffeda0", # configuración de códigos de color para la escala cromática
                      high = "#800026", name = "Población total")+
  xlab("Longitud") + ylab("Latitud")+
  ggtitle("Número de habitantes por sector catastral",
          subtitle = "Suave variabilidad")+
  theme(plot.title = element_text(hjust = 0.5))+
  coord_sf(xlim = c(st_bbox(pobla)[c(1,3)]),
           ylim = c(st_bbox(pobla)[c(2,4)]))# Delimita la extensión geográfica que se representar en el mapa 
   
#                                  #  
# Mapa de símbolos proporcionales  #
#                                  #

# Guardar
jpeg(filename = paste(rutas$figuras,"Símbolos proporcionales.jpeg",sep=""), width = 180, height = 180,
     units = "mm", res = 300)
# path to the geopackage file embedded in cartographytilesLayer(map1)
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
  legend.pos = "topright",  
  legend.title.txt = "Población total"
)
# Información de contexto
layoutLayer(title = "Número de habitantes por sector catastral",
            sources = "Fuente: SISBEN (2016)",
            author = paste0("Elaboración propia\nDatum:CTM12\nLibrería R: cartography ", packageVersion("cartography")),
            frame = FALSE, north = FALSE, tabtitle = TRUE)
# Flecha norte
north(pos = "topleft",south = FALSE)
dev.off()


#                                  #  
# Mapa Coropletas por quintiles    #
#                                  #

# Clasificar datos en quintiles
Quintiles<-as.integer(quantile(pobla$Pop_Tot, probs=seq(0,1,.2)))
Q<-c("[0%-20%]","[20.1%-40%]","[40.1%-60%]","[60.1%-80%]","[80.1%-100%]")
# Asignar rango por quintiles

for (i in seq_along(Quintiles)) {
  pobla$Quintiles[pobla$Pop_Tot<=Quintiles[2]]<-Q[1]
  pobla$Quintiles[pobla$Pop_Tot<=Quintiles[i]&pobla$Pop_Tot>Quintiles[i -1]]<-Q[i - 1]
}
rm(Q,Quintiles)
# Mapa por Quintiles
 m3<-ggplot() +
  annotation_scale()+
  annotation_north_arrow(location = "tr", which_north = "true", 
                         pad_x = unit(0.05, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering) +
   geom_sf(data = vias,fill="gray20",color="black", alpha = 0.2)+
  geom_sf(data = pobla, aes(fill = Quintiles), alpha = 0.99, color = "black") +
  scale_fill_brewer(palette = "YlOrRd",guide="legend") +
  theme_gray()+ # Modifica las características de fondo y delineado de retícula
  xlab("Longitud") + ylab("Latitud")+
   ggtitle("Número de habitantes por sector catastral",
          subtitle = "Clasificación por quintiles")+
   coord_sf(xlim = c(st_bbox(pobla)[c(1,3)]), ylim = c(st_bbox(pobla)[c(2,4)]))

 #                                      #  
 # Mapa Coropletas por Pretty-Breaks    #
 #                                     #
 PrettyBreaks<-pretty(pobla$Pop_Tot)
 P<-c("[0-2000]","[2001-4000]","[4001-6000]","[6001-8000]")
 
 for (i in seq_along(PrettyBreaks)) {
   pobla$PrettyBreaks[pobla$Pop_Tot<=PrettyBreaks[2]]<-P[1]
   pobla$PrettyBreaks[pobla$Pop_Tot<=PrettyBreaks[i]&pobla$Pop_Tot>PrettyBreaks[i - 1]]<-P[i - 1]
 }
 rm(P,PrettyBreaks)
 # Mapa Pretty Breaks
 
 m4<-ggplot() +
   annotation_scale()+
   annotation_north_arrow(location = "tr", which_north = "true", 
                          pad_x = unit(0.05, "in"), pad_y = unit(0.2, "in"),
                          style = north_arrow_fancy_orienteering) +
   geom_sf(data = vias,fill="gray20",color="black", alpha = 0.2)+
   geom_sf(data = pobla, aes(fill = PrettyBreaks), alpha = 0.99, color ="black") +
   scale_fill_brewer(palette = "YlOrRd",guide="legend") +
   theme_gray()+ # Modifica las características de fondo y delineado de retícula
   xlab("Longitud") + ylab("Latitud")+
   ggtitle("Número de habitantes por sector catastral",
           subtitle = "Quiebres de Pretty")+
   coord_sf(xlim = c(st_bbox(pobla)[c(1,3)]), ylim = c(st_bbox(pobla)[c(2,4)]))

 
 # Guardar gráficos
dir.create("Gráficos", recursive = TRUE)

 ggsave(filename = "Barras.jpeg",
        device = "jpeg",
        plot = Barras,
        width = 140,
        height = 140, 
        units = "mm", 
        dpi = 300,
        path = rutas$figuras)
 
 ggsave(filename = "Suave Variabilidad.jpeg"
        ,device = "jpeg",
        plot = m1,
        width = 180,
        height = 180,
        units = "mm",
        dpi = 300,
        path =rutas$figuras)
 
 ggsave(filename = "Símbolos proporcionales.jpeg"
        ,device = "jpeg",
        plot = m2,
        width = 180,
        height = 180,
        units = "mm",
        dpi = 300,
        path =rutas$figuras)
 
 ggsave(filename = "Coropletas por quintiles.jpeg"
        ,device = "jpeg",
        plot = m3,
        width = 180,
        height = 180,
        units = "mm",
        dpi = 300,
        path =rutas$figuras)
 
 ggsave(filename = "Coropletas por quiebres de Pretty.jpeg"
        ,device = "jpeg",
        plot = m4,
        width = 180,
        height = 180,
        units = "mm",
        dpi = 300,
        path =rutas$figuras)
 