library(terra)
library(sf)
library(tidyverse)

planetdir <- "/scratch/project_2007415/Planet/Iceland"

refr <- rast(paste0(planetdir, "/mosaiced/planet_2020-4-18_08-55-00_1052.tif"))

aoi <- st_read("data/AOI_Iceland.gpkg") %>% 
  st_transform(crs = crs(refr, proj = T))

dem1 <- rast(paste0(planetdir, "/IslandsDEMv1.0_2x2m_zmasl_isn2016_08.tif")) %>% 
  project(., refr)
dem2 <- rast(paste0(planetdir, "/IslandsDEMv1.0_2x2m_zmasl_isn2016_19.tif")) %>% 
  project(., refr)
dem <- mean(c(dem1, dem2), na.rm = T)

plot(dem)
names(dem) <- "elevation"
writeRaster(round(dem,2), paste0(planetdir, "/dem.tif"),
            overwrite = T)

slp <- terrain(dem, v="slope", neighbors=8, unit="degrees")
plot(slp)
names(slp)
writeRaster(round(slp,2), paste0(planetdir, "/slope.tif"),
            overwrite = T)

chm <- slp
names(chm) <- "chm"
chm[!is.na(chm)] <- 0
writeRaster(chm, paste0(planetdir, "/chm.tif"),
            overwrite = T)
