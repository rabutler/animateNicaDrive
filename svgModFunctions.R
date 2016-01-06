# from source('ex/manipulate_lowCO_borders_svg.R')
# then I added tmpKeep and changed attrs[tmpKeep] instead of being hard coded to 'd'
#' @param svg an open svg doc (see xml_doc <- xmlParse(svg_file, useInternalNode=TRUE))
#' @param ele_names a character vector equal in length to the number of path elements to name
#' @param keep.attrs a character vector of attributes to keep in original paths
#' @import XML
name_svg_elements <- function(svg, ele_names, keep.attrs = c('d')){
  require(XML)
  
  path_nodes <- XML::xpathApply(svg, "//*[local-name()='path']")
  for (i in 1:length(path_nodes)){
    attrs <- XML::xmlAttrs(path_nodes[[i]])
    tmpKeep <- keep.attrs[keep.attrs %in% names(attrs)] # can only keep those attrs that actually exist
    XML::removeAttributes(path_nodes[[i]])
    XML::addAttributes(path_nodes[[i]], .attrs = c(id=ele_names[i], attrs[tmpKeep])) 
  }
  
  invisible(svg)
}