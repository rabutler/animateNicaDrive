library(maptools)
library(magrittr)
library(maps)

library(rgeos) # only need if using gSimplify

# create the initial svg file from kml data, and add background map
createInitialSVG <- function(svgFile = 'driveRoute.svg')
{
  width <- height <- 8 # inches
  
  # kml files to read in, in the order they should be read in
  kmlFiles <- paste0(c('DrivingRoute1','DrivingRoute2', 'Ferry', paste0('DrivingRoute',3:6)),'.kml')
  
  # read in all the kml data, get coordinates, and bind together for all files
  r1 <- do.call(rbind, lapply(kmlFiles, function(x) 
    as.data.frame(maptools::getKMLcoordinates(paste0('data/',x),TRUE)[[1]])))
  
  names(r1) <- c('long','lat')
  
  # defProj <- CRS('+proj=longlat +datum=WGS84') # default used by maps package and google maps
  defProj <- CRS('+init=epsg:4326') # should be equivelant to previous statement
  
   # the lambert azimuth equal area roughly centered on mexico city
  myProj <- CRS('+proj=laea +lat_0=19 +lon_0=-99 +x_0=False +y_0=False')
  # the lambert conformal conic, set based on sites recomendations
  myProj <- CRS('+proj=lcc +lat_1=32 +lat_2=44 +lat_0=38 +lon_0=-100 +x_0=False +y_0=False')
  
  
  # create spatial lines from the kml data
  driveLine <- sp::Line(r1) %>% list() %>% sp::Lines(ID='drive-line') %>%
    list() %>% sp::SpatialLines(proj4string = defProj) %>% 
    sp::spTransform(myProj) %>%
    rgeos::gSimplify(tol = 500) # arbitrarily chosen tolerance but important; if you don't
                                # do the gSimplify, then the path appears jerky in some areas

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
  svg(filename = svgFile,width=width, height=height)
  par(mar = rep(0,4)) # remove margins
  plot(bgMap, col = 'grey15', border = 'grey50')
  plot(driveLine, col = 'steelblue3', add = T, lwd = 2.75) 
    
  dev.off()
  
}