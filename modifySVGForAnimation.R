
modifySVGForAnimation <- function(svgIn, svgOut, standAloneSVG = FALSE, jsScript = NA)
{
  svg <-  XML::xmlParse(svgIn, useInternalNode=TRUE)
  
  # get the number of paths in the document and arbitrarily name them 'myPath[n]'
  numPaths <- length(XML::xpathApply(svg, "//*[local-name()='path']"))
  
  # in the svg, the last path is the path I want to animate. call all of the other paths,
  # myPath[n], and the last path 'drivePath'
  pathNames <- c(paste0('myPath',1:(numPaths-1)),'drivePath')
  
  # and I want to keep all of the currently set styles
  keepAtts <- c('d','style')
  
  # name each of the paths
  svg <- name_svg_elements(svg, ele_names = pathNames, keep.attrs = keepAtts)
  
  # add javascript to the svg, if it will be a stand alone svg file
  if(standAloneSVG) svg <- add_ecmascript(svg, jsScript)
      
  # change the stroke-opacity of the drivePath
  svg <- svg %>% editPathStyle('drivePath','stroke-opacity','0') %>% 
    toString.XMLNode()
  
  cat(svg, file = paste0(svgOut), append = FALSE)
}
