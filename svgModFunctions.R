# adapted from: https://github.com/USGS-CIDA/OWDI-Lower-Colorado-Drought-Vis/blob/master/scripts/R/manipulate_lowCO_borders_svg.R
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

# copied from https://github.com/USGS-CIDA/OWDI-Lower-Colorado-Drought-Vis/blob/master/scripts/R/manipulate_lowCO_borders_svg.R
add_ecmascript <- function(svg, text){
  svg_nd <- XML::xpathApply(svg, "//*[local-name()='svg']")
  
  XML::newXMLNode('script', at=0, parent = svg_nd, attrs=c(type='text/ecmascript'), 
             newXMLTextNode(paste0(text,collapse='\n'), cdata = TRUE))
  
  invisible(svg)
  
}

# the "stand-alone" javascript to animate the path
animateDriveScript <- function(){
  c('var draw = function(){
var svgObj, svgDoc;
var path = document.getElementById("drivePath");
var length = path.getTotalLength();
path.style.transition = path.style.WebkitTransition = "none";
path.style.strokeDasharray = length + \' \' + length;
path.style.strokeDashoffset = length;
path.getBoundingClientRect();
path.style.transition = path.style.WebkitTransition ="stroke-dashoffset 10s linear";
path.style.strokeOpacity = "1";
path.style.strokeDashoffset= "0";
}
window.onload = function(){	
draw();
}'
  )
}

# edit the style attribute of a path element in the svg
# pathID: character of the path ID you want to edit
# attr2edit: character of the attribute inside the style attribute you want to edit
# attVal: the value you want to set the attr2edit to
# *** should make this work with multiple attributes
editPathStyle <- function(svg, pathID, attr2edit, attVal){
  path <- XML::xpathApply(svg,paste0("//*[local-name()='path'][@id='",pathID,"']"))[[1]]
  pAtts <- XML::xmlAttrs(path)
  # split pAtts['style'] on ; to get each style by itself, then split on ':' to get att and 
  # value as seperate rows
  styleMat <- simplify2array(strsplit(simplify2array(strsplit(pAtts['style'],';')),':'))
  # make the attr2edit equal to attVal
  styleMat[2,which(styleMat[1,]==attr2edit)] <- as.character(attVal)
  
  # now reconstruct the long string
  styleMat <- paste0(apply(styleMat,2,paste0,collapse=':'), collapse=';')
  pAtts['style'] <- styleMat
  XML::removeAttributes(path,.attrs = 'style')
  XML::addAttributes(path, .attrs = pAtts['style'])
  invisible(svg)
}
