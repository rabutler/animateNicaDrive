library(maptools)
library(magrittr)
library(maps)

# create the initial svg file from kml data, and add background map
createInitialSVG <- function(svgFile = 'driveRoute.svg', saveSVG = T)
{
  width <- height <- 7 # inches
  
  # start by reading in the driving route data from KML files
  r1 <- maptools::getKMLcoordinates('data/DrivingRoute1.kml', TRUE)
  r1 <- as.data.frame(r1[[1]])
  
  # kml files to read in, in the order they should be read in
  kmlFiles <- paste0(c('DrivingRoute2', 'Ferry', paste0('DrivingRoute',3:6)),'.kml')
  for(i in 1:length(kmlFiles)){
    
    kmlData <- maptools::getKMLcoordinates(paste0('data/',kmlFiles[i]),TRUE)
    kmlData <- as.data.frame(kmlData[[1]])
    kmlData <- kmlData[seq(1,nrow(kmlData),2),] # grab every other point to reduce size
    r1 <- rbind(r1,kmlData)
  }
  rm(kmlData)
  
  names(r1) <- c('long','lat')
  
  # defProj <- CRS('+proj=longlat +datum=WGS84') # default used by maps package and google maps
  defProj <- CRS('+init=epsg:4326') # should be equivelant to previous statement
  
   # the lambert azimuth equal area roughly centered on mexico city
  myProj <- CRS('+proj=laea +lat_0=19 +lon_0=-99 +x_0=False +y_0=False')
  # the lambert conformal conic, set based on sites recomendations
  myProj <- CRS('+proj=lcc +lat_1=32 +lat_2=44 +lat_0=38 +lon_0=-100 +x_0=False +y_0=False')
  
  
  # create spatial lines from the kml data
  driveLine <- Line(r1)
  driveLines <- Lines(list(driveLine), ID='drive-line')
  # driveLines is over 2MB at this point
  driveLineJ <- SpatialLines(list(driveLines), proj4string = defProj) %>% 
    spTransform(myProj)
  
  rm(driveLine,driveLines)
  
  # now add background map of states and countries we drove through
  
  # states
  # *** No idea why you have to have fill = T, but it won't work if fill = F
  # it still creates a seperate path for each state, but makes the R code easier.
  ss <- map('state', plot = F, fill = T)
  idS <- sapply(strsplit(ss$names, ':'), function(x) x[1])
  ssSt <- maptools::map2SpatialPolygons(ss, IDs=idS, proj4string=defProj) %>%
    spTransform(myProj)
  
  mx <- map('world',c('mexico','guatemala','nicaragua','el salvador','honduras','belize',
                      'costa rica','panama'),plot = F, fill = T, col = 'black')
  idMx <- sapply(strsplit(mx$names, ":"), function(x) x[1])
  ssMx <- maptools::map2SpatialPolygons(mx, IDs=idMx, proj4string=defProj) %>%
    spTransform(myProj)
  
  bgMap <- rbind(ssSt, ssMx) # rbind combines polygons for spatialPolygons
  
  # add them all to the svg
  if(saveSVG) svg(filename = svgFile,width=width, height=height)
  plot(bgMap, col = 'grey15', border = 'grey50')
  plot(driveLineJ, col = 'steelblue3', add = T, lwd = 2.75) 
    
  if(saveSVG) dev.off()
  
}