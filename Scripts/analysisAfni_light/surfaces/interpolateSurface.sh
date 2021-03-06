#!/usr/bin/env bash

MPRAGE=$1
SPECFILE='surfaces_folder/spec.surfaces.smoothed'
SURFACEFILEREG=(surfaces_folder/*_sm.1D.coord)

for (( i=0; i<${#SURFACEFILEREG[@]}; i++ )); do
   
   outputFileName[i]=$(printf '%s%s' ${SURFACEFILEREG[i]%%.*} '_surfval.1D')

   echo ${outputFileName[i]}
   echo ${SURFACEFILEREG[i]}
   
   3dVol2Surf                                  \
	       -spec         $SPECFILE	       	    \
	       -surf_A       ${SURFACEFILEREG[i]}   \
	       -sv           $MPRAGE                \
	       -grid_parent  $MPRAGE                \
	       -map_func     mask                   \
	       -out_1D       ${outputFileName[i]}

done
