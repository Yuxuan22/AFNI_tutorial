args <- commandArgs(T)
print( args )

tempName <- sprintf( '%s.temp', args[1] ) 
tempNameVolInstr1 <- sprintf( '%sWM.vol.temp', args[1] ) 
roiData <- read.table( args[1], comment.char='#' )
write.table( roiData[,1], file=tempName, col.names=FALSE, row.names=FALSE )
write.table( cbind( roiData[,1], rep( 1, dim(roiData)[1] ) ), file=tempNameVolInstr1, col.names=FALSE, row.names=FALSE )

# grow profiles based on normals and fill
commandLine <- sprintf("SurfToSurf -output_params NearestTriangleNodes NearestNode NearestTriangle DistanceToSurf ProjectionOnSurf NearestNodeCoords -i_1D %s_sm.1D.coord %s_or.1D.topo -i_1D %s_sm.1D.coord %s_or.1D.topo -node_indices %s -prefix SurfToSurfRoiTemp -closest_possible 0", args[2], args[2], args[3], args[3], tempName)
print( commandLine )
system(commandLine)

surfToSurfData <- read.table( 'SurfToSurfRoiTemp.1D', comment.char='#' )
tempNameVolInstr2 <- sprintf( '%sGM.vol.temp', args[1] )
filt <- abs( surfToSurfData[,12] )<4
surfToSurfDataFilt2 <- surfToSurfData[ filt, 2 ]
write.table( cbind( surfToSurfDataFilt2, rep( 1, length(surfToSurfDataFilt2) ) ), file=tempNameVolInstr2, col.names=FALSE, row.names=FALSE )

write.table( surfToSurfData[ filt, 1:2 ], file='delme.dat', col.names=FALSE, row.names=FALSE )


#nodesInstr1 <- read.table( tempNameVolInstr1, comment.char='#' )
#surfToSurfDataFilt1 <- nodesInstr1[ filt, ] 

#cbind( nodesInstr1Filt, surfToSurfDataFilt )
#wmBoundary <- read.table( sprintf('%s_sm.1D.coord', args[2] ) )
#gmBoundary <- read.table( sprintf('%s_sm.1D.coord', args[3] ) )

#library(AnalyzeFMRI)
#wmBoundary[surfToSurfDataFilt1,]
#cbind( wmBoundary[ nodesInstr1Filt, ], gmBoundary[ surfToSurfDataFilt, ] )

#get voxels on WM border
commandLine <- sprintf( '3dSurf2Vol -spec spec.surfaces.smoothed -surf_A %s_sm.1D.coord -sv %s -grid_parent %s -map_func mask -prefix %s -sdata_1D %s', args[2], args[4], args[4], 'surfVolWMRoi', tempNameVolInstr1 )
print( commandLine )
system( commandLine )

#get voxels on CSF border
commandLine <- sprintf( '3dSurf2Vol -spec spec.surfaces.smoothed -surf_A %s_sm.1D.coord -sv %s -grid_parent %s -map_func mask -prefix %s -sdata_1D %s', args[3], args[4], args[4], 'surfVolCSFRoi', tempNameVolInstr2 )
print( commandLine )
system( commandLine )

source('/usr/lib/afni/bin/AFNIio.R')
source('/home/alessiofracasso/Dropbox/analysisAfni/surfaces/coordinateFromLinearIndex.r')
library(SpatialTools)

wmBorderMask <- read.AFNI('surfVolWMRoi+orig')
gmLevelMask <- read.AFNI( args[5] )

maskData <- wmBorderMask$brk[,,,1]
gmData <- gmLevelMask$brk[,,,1]

emptyVol <- maskData
stepLimit <- 0.1
limit1 <- seq(0.1,1-stepLimit,by=stepLimit)
limit2 <- limit1 + stepLimit

for (lim in 1:length(limit1) ) {
  ind1 <- which( emptyVol==1 )
  ind2 <- which( gmData>limit1[lim] & gmData<=limit2[lim] )
  coordsWM <- matrix( t( coordinateFromLinearIndex( ind1, dim(emptyVol) ) ), ncol=3 )
  coordsGM <- matrix( t( coordinateFromLinearIndex( ind2, dim(emptyVol) ) ), ncol=3 )
  nSteps <- 30
  nXStep <- round( dim( coordsWM )[1] / nSteps )
  startArray <- seq( 1, dim( coordsWM )[1]-nXStep, by=nXStep )
  endArray <- startArray+nXStep
  endArray[ length(endArray) ] <- dim( coordsWM )[1]
  indexStore <- rep(0,nXStep)
  for (k in 1:length(startArray) ) {
    x1 <- coordsWM[ startArray[k]:endArray[k],  ]
    a <- dist2( x1, coordsGM )
    minVector <- apply(a, 1, min)
    for ( n in 1:dim(a)[1] ) {
      indexStore[n] <- which( minVector[n] == a[n,] )
    }  
    coords <- coordsGM[indexStore, ]
    for (l in 1:dim(coords)[1]) {
      emptyVol[ coords[l,1], coords[l,2], coords[l,3] ] <- 1
    }
  }
}

warnings()

roiFileName <- sprintf('%s+orig',args[1])
write.AFNI(roiFileName,
           brk=emptyVol,
           label=NULL,
           view='+orig',
           orient=wmBorderMask$orient,
           origin=wmBorderMask$origin,
           delta=wmBorderMask$delta,
           defhead=wmBorderMask$NI_head )


