library(maptools)
library(magrittr)
library(maps)

# create the initial svg file from kml data, and add background map
createInitialSVG <- function(svgFile = 'driveRoute.svg')
{
  width <- height <- 5
  
  # start by reading in the driving route data from KML files
  d1 <- maptools::getKMLcoordinates('data/DrivingRoute1.kml',TRUE)
  d2 <- maptools::getKMLcoordinates('data/DrivingRoute2.kml',TRUE)
  
  r1 <- as.data.frame(d1[[1]])
  r2 <- as.data.frame(d2[[1]])
  r1 <- rbind(r1,r2)
  names(r1) <- c('long','lat')
  rm(d1,d2,r2)
  
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
  ss <- map('state',c('colorado','new mexico','arizona','california'),plot = F, fill = T, col = 'blue')
  id1 <- sapply(strsplit(ss$names, ":"), function(x) x[1])
  ssSp <- maptools::map2SpatialPolygons(ss, IDs=id1, proj4string=CRS(myProj)) %>%
    spTransform(CRS(epsg_code)) 
  
  # *** No idea why you have to have fill = T, but it won't work if fill = F
  # the choice of color really doesn't matter as the color will be set in the future when we 
  # pass it to plot()
  mx <- map('world','mexico',plot = F, fill = T, col = 'black')
  idMx <- sapply(strsplit(mx$names, ":"), function(x) x[1])
  ssMx <- maptools::map2SpatialPolygons(mx, IDs=idMx, proj4string=CRS(myProj)) %>%
    spTransform(CRS(epsg_code))
  
  # add them all to the svg
  svg(filename = svgFile,width=width, height=height)
    # *** for now adding the route first uses the algorithm in sp.plot to figure out 
    # *** the extents. But it means that initial the line will be hidden behind the states
    plot(driveLineJ,col = 'red') 
    plot(ssSp, col = 'blue',add = T)
    plot(ssMx, col = 'blue',add = T)
    
  dev.off()
  
}