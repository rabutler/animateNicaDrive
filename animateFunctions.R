
# From CRDrough/manipulate_lowCO_borders_svg.R
add_animation <- function(svg, attr, parent_id, element = 'path', ...){
  attrs <- expand.grid(..., stringsAsFactors = FALSE)
  parent_nd <- XML::xpathApply(svg, sprintf("//*[local-name()='%s'][@id='%s']",element, parent_id))
  XML::newXMLNode('animate', parent = parent_nd, 
             attrs = c('attributeName'=attr, attrs))
  invisible(svg)
  
}