library(tidyverse, quiet = TRUE)
library(raster, quiet = TRUE)
# install.packages("RStoolbox", lib ="/projappl/project_2003061/Rpackages")
library(RStoolbox, lib.loc = "/projappl/project_2003061/Rpackages")
library(foreach, quiet = TRUE)
library(doMPI, quiet = TRUE)

setwd("/projappl/project_2007415/repos/Iceland_SCD")
planetdir <- "/scratch/project_2007415/Planet/Iceland"

img_df <- read_csv("data/selected_planets.csv")

if(!dir.exists(paste0(planetdir,"/coregistered"))){
  dir.create(paste0(planetdir,"/coregistered"))
}

# monthly medians

master_snowy <- stack(paste0(planetdir, "/mosaiced/planet_2020-4-18_08-55-00_1052.tif"))
master_snowfree <- stack(paste0(planetdir, "/mosaiced/planet_2021-4-14_11-49-00_2441.tif"))

master_snowy <- coregisterImages(master_snowy, ref = master_snowfree, shift = 5, verbose = F,
                           nSamples = 20000, reportStats = F)

img_df %>% mutate(exsts = f %in% list.files(paste0(planetdir, "/coregistered/")))

tifs <- img_df %>% filter((!grepl(substr(names(master_snowy)[1],1,30), f)) &
                            (!grepl(substr(names(master_snowfree)[1],1,30), f))) %>% pull(f)


cl<-startMPIcluster()
registerDoMPI(cl)
foreach(i = tifs, .packages = c("raster")) %dopar% {
# for(i in tifs){
  # i <- tifs[2]
  # i <- "planet_2019-4-25_12-05-00_1013.tif"
  # print(i)
  if(!file.exists(paste0(planetdir, "/coregistered/", i))){
    
    rtemp <- stack(paste0(planetdir, "/mosaiced/",i))
    # rtemp <- crop(rtemp, bbox(rtemp)-1000)
    # plot(rtemp)
    
    library(RStoolbox, lib.loc = "/projappl/project_2003061/Rpackages")
    
    meanref <- mean(values(rtemp[[1]]), na.rm = T)
    
    if(meanref > 1500){
      rtemp2 <- coregisterImages(rtemp, ref = master_snowy, shift = 10, verbose = F,
                                nSamples = 20000, reportStats = F)
    } else (
      rtemp2 <- coregisterImages(rtemp, ref = master_snowfree, shift = 10, verbose = F,
                                nSamples = 20000, reportStats = F)
    )
    
    writeRaster(rtemp2, paste0(planetdir, "/coregistered/", i),
                datatype = "INT2U", overwrite = T)
    
    i
  }
  
}

writeRaster(master_snowy, paste0(planetdir, "/coregistered/planet_2020-4-18_08-55-00_1052.tif"),
            datatype = "INT2U", overwrite = T)

writeRaster(master_snowfree, paste0(planetdir, "/coregistered/planet_2021-4-14_11-49-00_2441.tif"),
            datatype = "INT2U", overwrite = T)
