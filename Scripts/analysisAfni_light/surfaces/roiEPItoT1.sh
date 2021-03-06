#!/bin/bash

ROI=$1
EPI=$2
MPRAGE=$3
CMMATRIX=$4
ALMATRIX=$5
CLIP=$6
CLIPDIRECTION=$7
NAME=$8

#ROI='prfModelOutput_011316_174457+orig'
#EPI='amplitudeAnatomy.nii.gz'
#MPRAGE='anatomy_crop.nii.gz'
#CMMATRIX='MPRAGE_zp_shft.1D'
#ALMATRIX='MPRAGE_zp_shft_mask_unif_al_mat.aff12.1D'
#CLIP=8
#NAME='t1_al'

3dcopy ${MPRAGE} MPRAGE+orig
3dcopy ${EPI} EPI+orig
3dcopy ${ROI} ROI+orig

instr=$(printf '@clip_volume -%s %d -input MPRAGE+orig -verb -prefix MPRAGE_crop+orig' $CLIPDIRECTION $CLIP )
$instr
#@clip_volume -anterior $CLIP -input MPRAGE+orig -verb -prefix MPRAGE_crop+orig

3dZeropad -z 10 -prefix MPRAGE_zp+orig MPRAGE_crop+orig
3dZeropad -z 10 -prefix EPI_zp+orig EPI+orig
3dZeropad -z 10 -prefix ROI_zp+orig ROI+orig

3dAllineate   -1Dmatrix_apply ${CMMATRIX}    \
                    -prefix MPRAGE_zp_cm+orig \
		    -master EPI_zp+orig \
                    -input MPRAGE_zp+orig

cat_matvec ${ALMATRIX} -I -ONELINE > inv.aff12_1.1D

3dAllineate   -1Dmatrix_apply inv.aff12_1.1D    \
                    -prefix ROI_zp_al+orig -master MPRAGE_zp_cm+orig \
                    -input ROI_zp+orig \
		    -final NN	

cat_matvec ${CMMATRIX} -I -ONELINE > inv.aff12_2.1D

3dAllineate   -1Dmatrix_apply inv.aff12_2.1D    \
                    -prefix ROI_zp_al_mprage+orig \
		    -master MPRAGE_zp+orig \
                    -input ROI_zp_al+orig \
		    -final NN


3dZeropad -z -10 -prefix ROI_zp_al_mprage_nozp+orig ROI_zp_al_mprage+orig

3dAFNItoNIFTI -prefix $( printf '%s_al_mprage' ${NAME} ) ROI_zp_al_mprage_nozp+orig
gzip $( printf '%s_al_mprage.nii' ${NAME} )


rm MPRAGE*.BRIK
rm MPRAGE*.HEAD
rm ROI*.BRIK
rm ROI*.HEAD
rm EPI*.BRIK
rm EPI*.HEAD
rm inv.aff12_1.1D
rm inv.aff12_2.1D


