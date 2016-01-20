# References:

# from: http://stackoverflow.com/questions/8751497/latitude-longitude-coordinates-to-state-code-in-r/8751965#8751965
states <- map('state', fill=TRUE, col="transparent", plot=FALSE)
IDs <- sapply(strsplit(states$names, ":"), function(x) x[1])
myProj <- '+proj=utm +zone=12 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0'

states_sp <- map2SpatialPolygons(states, IDs=IDs,proj4string=CRS(myProj))

# using svglite package does not allow fine enough control of the types of elements
# or adding specific class and ids

# selecting svg inside of object tags:
# https://benfrain.com/selecting-svg-inside-tags-with-javascript/
