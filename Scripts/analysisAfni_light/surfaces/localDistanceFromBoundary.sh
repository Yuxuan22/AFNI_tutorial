#!/bin/bash

ROINAME=$1
THRESHOLD=$2
BOUNDARY=$3
DIRECTORYSURFACES=$4
COLUMNINDEXSURFACES=$5

if [ -z "$1" ]
then

echo
echo
echo 'computes a distance map with respect to a boundary defined by the threshold value provided,'
echo 'useful for PSF estimation over the surface'
echo
echo
echo 'Inputs:'
echo 'ROINAME=$1, e.g. roiname defined around the boundary'
echo 'THRESHOLD=$2, e.g. threshold over which the boundary is defined'
echo 'BOUNDARY=$3, e.g. boundary05, generated by generateSurfaces.sh'
echo 'DIRECTORYSURFACES=$4, directory where the surfaces are projected, probably you want to smooth heavily too'
echo 'COLUMNINDEXSURFACES=$5 column index of interest from the surfaces file'

exit 1
fi


Rscript $AFNI_TOOLBOXDIR/surfaces/localDistanceFromBoundary.R \
$ROINAME \
$THRESHOLD \
$BOUNDARY \
$DIRECTORYSURFACES \
$COLUMNINDEXSURFACES \
$AFNI_INSTALLDIR \
$AFNI_TOOLBOXDIR
