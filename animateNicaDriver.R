# animate the route we took driving from CO to Nicaragua
source('createInitialSVG.R')
source('svgModFunctions.R')
source('modifySVGForAnimation.R')

# creates the initial SVG; 
# I should make the map look pretty inside that function

if(FALSE) createInitialSVG()

if(TRUE){ 
  modifySVGForAnimation('driveRoute.svg', '~/rabutler.github.io/images/driveRoute.svg')
  modifySVGForAnimation('driveRoute.svg', 'driveRoute2.svg', TRUE, animateDriveScript())
}
  