library(svglite)
library(ggplot2)
library(magrittr)
library(XML)
source('animateFunctions.R')

oPath <- '~/rabutler.github.io/images/test/'

createBasicSVG <- function(){
  # create a super simple svg
  
  zz <- data.frame(x = c(1,1,2,2), xend = c(1,2,2,1), y = c(1,2,2,1), yend = c(2,2,1,1))
  zPath <- data.frame(x = c(seq(1.9,1.1,-.05),seq(1.1,1.9,.05)), 
                      y = c(seq(1.9,1.1,-.05),rep(1.1,length(seq(1.1,1.9,.05)))))
  
  ggFig <- ggplot(zz, aes(x=x,y=y)) + geom_segment(aes(xend=xend,yend=yend),size=3) + 
    geom_path(data = zPath, aes(x=x,y=y), color = 'blue',size=2) + 
    theme(axis.line = element_blank(), panel.background = element_blank(), 
          panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
          axis.text = element_blank(), axis.title = element_blank(), 
          axis.ticks = element_blank())
  
  ##svglite::htmlSVG(print(ggFig))
  
  svglite::svglite(paste0(oPath,"test.svg"),width = 2, height = 2)
  print(ggFig)
  dev.off()
}

# manually edited svg as follows:
# - added id = "anLine" to the polyline created by above function
# - changed polyline to path
# - changed points=" to d="M
# - added CSS code from codepen to SVG
# - added js to html page pointing to the svg; 
#   - This is probably still not working as the lines are still too short.


#animateLine <- function(){
  svg <- XML::xmlParse(paste0(oPath,'myfile.svg'), useInternalNode=TRUE)
  svg2 <- svg %>% add_animation(attr = 'stroke-dashoffset', parent_id='anLine', 
                                id = 'draw-anLine', begin="indefinite", fill="freeze", 
                                dur="5s", values="351;0;")
  
  svg2 <- XML::toString.XMLNode(svg2)
  lines <- strsplit(svg2,'[\n]')[[1]]
  cat(paste(c(lines[1], lines[-1]),collapse = '\n'), file = paste0(oPath,'myfile_edit.svg'), append = FALSE)
  
#}
