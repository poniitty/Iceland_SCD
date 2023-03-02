# install.packages("RStoolbox", lib = "/projappl/project_2003061/Rpackages/")
library(raster, quiet = TRUE)
library(sf, quiet = TRUE)
library(tidyverse, quiet = TRUE)
library(lubridate, quiet = TRUE)
library(RStoolbox, lib.loc = "/projappl/project_2003061/Rpackages/")
library(foreach, quiet = TRUE)
library(doMPI, quiet = TRUE)

planetdir <- "/scratch/project_2007415/Planet/Iceland"

df <- tibble(f = list.files(paste0(planetdir, "/files/"), pattern = "_SR_")) %>% 
  mutate(year = as.numeric(substr(f, 1, 4)),
         month = as.numeric(substr(f, 5, 6)),
         day = as.numeric(substr(f, 7, 8)),
         utc_time = hm(paste(as.numeric(substr(f, 10, 11)),
                      substr(f, 12, 13), sep = ":")))

extr_satid <- function(x){
  satid <- strsplit(x, "_")[[1]][3]
  if(nchar(satid) < 3){
    satid <- strsplit(x, "_")[[1]][4]
  }
  return(satid)
}

df <- df %>% mutate(sat_id = unlist(lapply(f, extr_satid)))

df %>% arrange(year, month, day, utc_time) %>% 
  group_by(year, month, day, sat_id) %>% 
  mutate(groupid = cur_group_id()) %>% 
  ungroup() -> df

if(!dir.exists(paste0(planetdir,"/mosaiced"))){
  dir.create(paste0(planetdir,"/mosaiced"))
}

cl<-startMPIcluster()
registerDoMPI(cl)
print(cl)
foreach(gid = unique(df$groupid)) %dopar% {
  #ddate <- dirdates[25]
  # gid <- 6
  library(raster)
  library(sf)
  library(dplyr)
  library(lubridate)
  library(RStoolbox, lib.loc = "/projappl/project_2003061/Rpackages/")
  
  if(nrow(df %>% filter(groupid == gid)) > 1){
    
    r1 <- stack(df %>% filter(groupid == gid) %>% slice(1) %>% pull(f) %>% paste0(planetdir, "/files/", .))
    
    for(rid in df %>% filter(groupid == gid) %>% slice(-1) %>% pull(f) %>% paste0(planetdir, "/files/", .)){
      rtemp <- stack(rid)
      
      e <- try({
        rtemp <- coregisterImages(rtemp, ref = r1, shift = 5, verbose = T,
                                  nSamples = 10000, reportStats = TRUE)$coregImg
        
        r1 <- mosaic(r1, rtemp, fun = 'mean')
      }, silent = T)
      if(class(e) == "try-error"){
        r1 <- mosaic(r1, rtemp, fun = 'mean')
      }
    }
  } else {
    r1 <- stack(df %>% filter(groupid == gid) %>% slice(1) %>% pull(f) %>% paste0(planetdir, "/files/", .))
  }
  
  df %>% filter(groupid == gid) %>% slice(1) %>% pull(utc_time) -> t1
  
  writeRaster(r1, paste0(planetdir, "/mosaiced/planet_",
                         paste(df %>% filter(groupid == gid) %>% slice(1) %>% pull(year),
                               df %>% filter(groupid == gid) %>% slice(1) %>% pull(month),
                               df %>% filter(groupid == gid) %>% slice(1) %>% pull(day),
                               sep = "-"), "_",
                         format(Sys.Date() + t1, "%H-%M-%S"), "_",
                         df %>% filter(groupid == gid) %>% slice(1) %>% pull(sat_id),
                         ".tif"),
              format = "GTiff", datatype = "INT2U", overwrite = T)
}
closeCluster(cl)
mpi.quit()

df <- tibble(f = list.files(paste0(planetdir, "/mosaiced/"), pattern = "planet_.*.tif$")) %>% 
  mutate(date = ymd(unlist(lapply(f, function(x) strsplit(x, "_")[[1]][2])))) %>% 
  mutate(year = year(date),
         month = month(date)) %>% 
  mutate(utc_time = unlist(lapply(f, function(x) strsplit(x, "_")[[1]][3]))) %>% 
  mutate(sat_id = unlist(lapply(f, function(x) strsplit(x, "_")[[1]][4]))) %>% 
  mutate(sat_id = gsub(".tif","",sat_id))

df <- df %>% mutate(sat_id = unlist(lapply(f, extr_satid)))

df <- df %>% arrange(date, utc_time)

write_csv(df, "data/image_info.csv")