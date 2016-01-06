# animate the route we took driving from CO to Nicaragua
source('createInitialSVG.R')
source('svgModFunctions.R')

# creates the initial SVG; 
# I should make the map look pretty inside that function
createInitialSVG()


# get the number of paths in the document and arbitrarily name them 'myPath[n]'
# and I want to keep all of the currently set properties; for now.
svgFile <- 'driveRoute.svg'
svg <-  XML::xmlParse(svgFile, useInternalNode=TRUE)
numPaths <- length(XML::xpathApply(svg, "//*[local-name()='path']"))
pathNames <- paste0('myPath',1:numPaths)
keepAtts <- c('d','style')

svg <- #clean_svg_doc(svg) %>%
  name_svg_elements(svg, ele_names = pathNames, keep.attrs = keepAtts) %>% 
  toString.XMLNode()

cat(svg, file = 'driverRouteEdit.svg', append = FALSE)

# write out SVG;
# using svglite package does not allow fine enough control of the types of elements
# or adding specific class and ids

