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

# in the svg, the last path is the path I want to animate. call all of the oher paths,
# myPath[n], and the last path 'drivePath'
pathNames <- c(paste0('myPath',1:(numPaths-1)),'drivePath')
keepAtts <- c('d','style')

svg <- #clean_svg_doc(svg) %>%
  name_svg_elements(svg, ele_names = pathNames, keep.attrs = keepAtts) %>% 
  toString.XMLNode()

OFolder <- '~/rabutler.github.io/images/'
cat(svg, file = paste0(OFolder,svgFile), append = FALSE)
