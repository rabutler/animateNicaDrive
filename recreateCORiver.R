# try and recreate the colorado river animation, scene 1.
source('ex/manipulate_lowCO_borders_svg.R')
source('ecmaScript.R')

svg_file = 'ex/coRiverStart.svg'
oPath <- '~/rabutler.github.io/images/test/'
co_river_styles = c('style'="stroke-dasharray:351;stroke-dashoffset:351;stroke-linejoin:round;stroke-linecap:round;")
declaration <- '<?xml-stylesheet type="text/css" href="svg.css" ?>'


svg <- xmlParse(svg_file, useInternalNode=TRUE)
svg2 <- svg %>%
  #add_ecmascript(ecmascript_coRiver()) %>%
  attr_svg_groups(attrs = list('co-river-polyline' = co_river_styles)) %>%
  add_animation(attr = 'stroke-dashoffset', parent_id='Colorado-river', id = 'draw-colorado-river', begin="indefinite", fill="freeze", dur='5s', values="351;0;") #%>%
  #add_animation(attr = 'stroke-dashoffset', parent_id='Colorado-river', id = 'reset-colorado-river', begin="indefinite", fill="freeze", dur=ani_dur[['river-reset']], values="0;351;") %>%

oFile <- 'nextSvg.svg'  
svg2 <- toString.XMLNode(svg2)
lines <- strsplit(svg2,'[\n]')[[1]]
cat(paste(c(lines[1], declaration, lines[-1]),collapse = '\n'), file = paste0(oPath,oFile), append = FALSE)
