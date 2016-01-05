# animate the route we took driving from CO to Nicaragua

# read in kgb data

library(maptools)
d1 <- maptools::getKMLcoordinates('data/DrivingRoute1.kml',TRUE)
d2 <- maptools::getKMLcoordinates('data/DrivingRoute2.kml',TRUE)

r1 <- as.data.frame(d1[[1]])
r2 <- as.data.frame(d2[[1]])
r1 <- rbind(r1,r2)
names(r1) <- c('long','lat')

# preview the line in R
library(ggplot2)
library(maps)

usamap <- ggplot2::map_data("world")
gg <- ggplot() + geom_polygon(data = usamap, aes(x = long, y = lat, group = group)) +
  coord_cartesian(xlim = c(-70,-125), ylim = c(5,40))

gg <- gg + geom_point(data = r1, aes(x = long, y = lat), color = 'red', size = 3)
print(gg)

# create an SVG path from r1, or d1/d2?
svgFile <- 'driveRoute.svg'
width <- height <- 5
epsg_code <- '+init=epsg:3479'
simp_tol <- 7000

driveLine <- Line(r1)
driveLines <- Lines(list(driveLine), ID='drive-line')
# driveLines is over 2MB at this point
driveLineJ <- SpatialLines(list(driveLines), proj4string = CRS('+proj=utm +zone=12 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0'))

svg(filename = svgFile,width=width, height=height)
spTransform(driveLineJ, CRS(epsg_code)) %>%
  #rgeos::gSimplify(simp_tol) %>%
  plot()
dev.off()

# **** Still to do: get ID in the driving line
# **** See: ex/build_lowCO_borders_svg.R

# write out SVG;
# using svglite package does not allow fine enough control of the types of elements
# or adding specific class and ids

