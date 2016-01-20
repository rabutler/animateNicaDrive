library(maptools)
library(magrittr)
library(maps)

# create the initial svg file from kml data, and add background map
createInitialSVG <- function(svgFile = 'driveRoute.svg', saveSVG = T)
{
  width <- height <- 5
  
  # start by reading in the driving route data from KML files
  r1 <- maptools::getKMLcoordinates('data/DrivingRoute1.kml', TRUE)
  r1 <- as.data.frame(r1[[1]])
  
  # kml files to read in, in the order they should be read in
  kmlFiles <- paste0(c('DrivingRoute2', 'Ferry', paste0('DrivingRoute',3:6)),'.kml')
  #kmlFiles <- c('DrivingRoute2.kml','Ferry.kml','DrivingRoute3.kml','DrivingRoute4.kml','DrivingRoute5.kml','DrivingRoute6.kml')
  for(i in 1:length(kmlFiles)){
    
    kmlData <- maptools::getKMLcoordinates(paste0('data/',kmlFiles[i]),TRUE)
    kmlData <- as.data.frame(kmlData[[1]])
    kmlData <- kmlData[seq(1,nrow(kmlData),2),] # grab every other point to reduce size
    r1 <- rbind(r1,kmlData)
  }
  rm(kmlData)
  
  names(r1) <- c('long','lat')
  
  epsg_code <- '+init=epsg:3479'
  #simp_tol <- 7000
  
  # create spatial lines from the kml data
  driveLine <- Line(r1)
  driveLines <- Lines(list(driveLine), ID='drive-line')
  # driveLines is over 2MB at this point
  driveLineJ <- SpatialLines(list(driveLines), proj4string = CRS('+proj=utm +zone=12 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0'))
  
  driveLineJ <- spTransform(driveLineJ, CRS(epsg_code))
  
  rm(driveLine,driveLines)
  
  # now add background map of states and countries we drove through
  
  # states
  myProj <- '+proj=utm +zone=12 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0'
  
  # states together
  # it still creates a seperate path for each state, but makes the R code easier.
  ss <- map('state',c('colorado','new mexico','arizona','utah','nevada','california','texas'), plot = F,fill = T)
  id1 <- sapply(strsplit(ss$names, ":"), function(x) x[1])
  ssSp <- maptools::map2SpatialPolygons(ss, IDs=id1, proj4string=CRS(myProj)) %>%
    spTransform(CRS(epsg_code)) 
  
  # *** No idea why you have to have fill = T, but it won't work if fill = F
  # the choice of color really doesn't matter as the color will be set in the future when we 
  # pass it to plot()
  mx <- map('world',c('mexico','guatemala','nicaragua','el salvador','honduras','belize'),plot = F, fill = T, col = 'black')
  idMx <- sapply(strsplit(mx$names, ":"), function(x) x[1])
  ssMx <- maptools::map2SpatialPolygons(mx, IDs=idMx, proj4string=CRS(myProj)) %>%
    spTransform(CRS(epsg_code))
  
  bgMap <- rbind(ssMx, ssSp) #rbind combines polygons for spatialPolygons
  
  # add them all to the svg
  if(saveSVG) svg(filename = svgFile,width=width, height=height)
  # *** for now adding the route first uses the algorithm in sp.plot to figure out 
  # *** the extents. But it means that initial the line will be hidden behind the states
  plot(driveLineJ,col = 'red') 
  plot(bgMap, col = 'black', add = T, border = 'grey50')
  # redundant, but gets it to be the last layer and appear on top
  plot(driveLineJ, col = 'steelblue3', add = T, lwd = 2.5) 
    
  if(saveSVG) dev.off()
  
}