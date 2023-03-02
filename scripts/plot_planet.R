###########################################################################################################
## PLOT ALL PLANETS

library(raster, quiet = TRUE)
library(sf, quiet = TRUE)
library(tidyverse, quiet = TRUE)
library(lubridate, quiet = TRUE)

planetdir <- "/scratch/project_2007415/Planet/Iceland"

tifs <- list.files(paste0(planetdir, "/mosaiced"), pattern = ".tif$", full.names = T)
tifs <- sort(tifs)

pdf("visuals/PlanetScenes.pdf", 8, 8)
for(rasters in tifs){
  print(which(tifs == rasters))
  stemp <- stack(rasters)
  stemp[stemp > 8000] <- 8000
  plotRGB(stemp, r=4, g=3, b=2, scale = 8000)
  legend("top", legend = NA, title = rasters, bty = "n", cex = 1.3)
}
dev.off()

# Go through the plots

# Completely cloud free

sels <- c("planet_2019-3-11_12-04-00_0f52",
  "planet_2019-3-19_09-52-00_0f44",
  "planet_2019-3-26_12-09-00_1039",
  "planet_2019-3-28_09-50-00_1048",
  "planet_2019-3-30_12-08-00_1005",
  "planet_2019-3-5_12-08-00_1025",
  "planet_2019-4-10_12-07-00_1014",
  "planet_2019-4-10_12-07-00_1035",
  "planet_2019-4-11_09-47-00_1053",
  "planet_2019-4-25_12-05-00_1013",
  "planet_2019-4-4_12-04-00_1038",
  "planet_2019-4-7_12-06-00_1002",
  "planet_2019-4-8_12-06-00_1038",
  "planet_2019-4-9_12-06-00_0f34",
  "planet_2019-5-15_09-43-00_104b",
  "planet_2019-5-17_09-44-00_0f46",
  "planet_2019-6-11_11-11-00_106f",
  "planet_2019-6-16_09-42-00_1052",
  "planet_2019-6-7_11-09-00_1065",
  "planet_2020-3-16_12-09-00_103c",
  "planet_2020-3-19_12-11-00_0f15",
  "planet_2020-3-23_11-59-00_0e19",
  "planet_2020-3-24_12-10-00_103c",
  "planet_2020-3-25_11-59-00_0e20",
  "planet_2020-3-26_09-00-00_104a",
  "planet_2020-3-27_09-00-00_0f21",
  "planet_2020-3-28_12-10-00_1009",
  "planet_2020-3-28_12-11-00_103c",
  "planet_2020-3-4_11-57-00_0e0f",
  "planet_2020-4-14_10-55-00_1067",
  "planet_2020-4-16_08-51-00_0f49",
  "planet_2020-4-17_12-08-00_100c",
  "planet_2020-4-18_08-55-00_1052",
  "planet_2020-5-19_12-09-00_1003",
  "planet_2020-5-24_10-46-00_1065",
  "planet_2020-5-30_12-08-00_1032",
  "planet_2020-5-3_08-48-00_0f2a",
  "planet_2021-2-15_12-14-00_101f",
  "planet_2021-2-18_12-12-00_0f15",
  "planet_2021-2-18_12-14-00_0f17",
  "planet_2021-2-28_11-54-00_2441",
  "planet_2021-3-16_12-33-00_2419",
  "planet_2021-3-18_12-08-00_1005",
  "planet_2021-3-22_11-42-00_2235",
  "planet_2021-3-22_12-36-00_2408",
  "planet_2021-3-25_12-15-00_1003",
  "planet_2021-3-27_12-15-00_101b",
  "planet_2021-3-30_12-26-00_105c",
  "planet_2021-3-3_12-42-00_227a",
  "planet_2021-3-5_12-57-00_1058",
  "planet_2021-4-10_12-13-00_100a",
  "planet_2021-4-12_11-42-00_245f",
  "planet_2021-4-13_12-34-00_2413",
  "planet_2021-4-14_11-49-00_2441",
  "planet_2021-4-16_11-47-00_2460",
  "planet_2021-4-23_12-08-00_1008",
  "planet_2021-4-27_11-45-00_2456",
  "planet_2021-4-2_11-48-00_2206",
  "planet_2021-4-9_12-10-00_1009",
  "planet_2021-5-12_10-35-00_1065",
  "planet_2021-5-12_12-07-00_103c",
  "planet_2021-5-27_12-32-00_2408",
  "planet_2021-5-31_12-11-00_1010",
  "planet_2021-6-24_12-10-00_1012",
  "planet_2021-6-24_12-12-00_1011",
  "planet_2022-2-27_11-36-00_2449",
  "planet_2022-2-27_12-03-00_1035",
  "planet_2022-3-12_12-11-00_247c",
  "planet_2022-3-15_12-07-00_1005",
  "planet_2022-3-18_11-39-00_245c",
  "planet_2022-3-18_11-42-00_241d",
  "planet_2022-3-5_11-44-00_242d",
  "planet_2022-3-8_12-11-00_105c",
  "planet_2022-4-10_11-38-00_2439",
  "planet_2022-4-21_12-14-00_2495",
  "planet_2022-4-23_12-21-00_2416",
  "planet_2022-4-30_12-26-00_2405",
  "planet_2022-5-28_12-10-00_2488",
  "planet_2022-5-31_11-45-00_2421",
  "planet_2022-5-31_12-05-00_24a5")

sels <- paste0(sels, ".tif")

imgs <- read_csv("data/image_info.csv")
imgs <- imgs %>% 
  filter(f %in% sels)

write_csv(imgs, "data/selected_planets.csv")

# For cloud masking

