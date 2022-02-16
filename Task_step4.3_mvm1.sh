#!/bin/bash

workDir=/Volumes/Yorick/ZZ_Archive/KnowFiltMISQ/derivatives
outDir=${workDir}/grp-Revision2
mask=${outDir}/Intersection_GM_mask+tlrc
refFile=${workDir}/sub-8107/run-01_knowfilt_scale+tlrc
blurInt=8
deconvFile=deconv_phase1
print=${outDir}/ACF_raw_${deconvFile}.txt
cd $workDir

# blur, determine parameter estimate

if [ ! -f $print ]; then

	for k in sub-81*; do
	    cd $k
	    
		for m in stats errts; do

			# blur
			if [ ! -f ${deconvFile}_${m}_blur${blurInt}+tlrc.HEAD ]; then
				3dmerge -prefix ${deconvFile}_${m}_blur${blurInt} -1blur_fwhm $blurInt -doall ${deconvFile}_${m}+tlrc
			fi
		done

		# parameter estimate
		3dFWHMx -mask $mask -input ${deconvFile}_errts_blur${blurInt}+tlrc -acf >> $print
		cd $workDir
	done

fi

cd $outDir

# simulate noise, determine thresholds
if [ ! -s ${outDir}/ACF_MC_${deconvFile}.txt ]; then

	sed '/ 0  0  0    0/d' $print > tmp

	xA=`awk '{ total += $1 } END { print total/NR }' tmp`
	xB=`awk '{ total += $2 } END { print total/NR }' tmp`
	xC=`awk '{ total += $3 } END { print total/NR }' tmp`

	3dClustSim -mask $mask -LOTS -iter 10000 -acf $xA $xB $xC > ACF_MC_${deconvFile}.txt
	rm tmp
fi

3dMVM -prefix ${outDir}/MVM2_blur -jobs 10 \
 -mask $mask \
 -wsVars 'Phase*Expectation*Outcome' \
 -num_glt 3 \
 -gltLabel 1 P1_Expt          -gltCode 1 'Phase: 1*P1 Expectation: 1*HI1 -1*LO1' \
 -gltLabel 2 P1_ExptXOutcome  -gltCode 2 'Phase: 1*P1 Expectation: 1*HI1 -1*LO1 Outcome: 1*HI2 -1*LO2' \
 -gltLabel 3 P2_ExptXOutcome  -gltCode 3 'Phase: 1*P2 Expectation: 1*HI1 -1*LO1 Outcome: 1*HI2 -1*LO2' \
 -dataTable \
 Subj Phase	Expectation	Outcome	InputFile \
 sub-8107	P1	HI1	HI2	${workDir}/sub-8107/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8107	P1	HI1	LO2	${workDir}/sub-8107/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8107	P1	LO1	HI2	${workDir}/sub-8107/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8107	P1	LO1	LO2	${workDir}/sub-8107/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8107	P2	HI1	HI2	${workDir}/sub-8107/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8107	P2	HI1	LO2	${workDir}/sub-8107/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8107	P2	LO1	HI2	${workDir}/sub-8107/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8107	P2	LO1	LO2	${workDir}/sub-8107/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8108	P1	HI1	HI2	${workDir}/sub-8108/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8108	P1	HI1	LO2	${workDir}/sub-8108/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8108	P1	LO1	HI2	${workDir}/sub-8108/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8108	P1	LO1	LO2	${workDir}/sub-8108/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8108	P2	HI1	HI2	${workDir}/sub-8108/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8108	P2	HI1	LO2	${workDir}/sub-8108/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8108	P2	LO1	HI2	${workDir}/sub-8108/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8108	P2	LO1	LO2	${workDir}/sub-8108/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8109	P1	HI1	HI2	${workDir}/sub-8109/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8109	P1	HI1	LO2	${workDir}/sub-8109/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8109	P1	LO1	HI2	${workDir}/sub-8109/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8109	P1	LO1	LO2	${workDir}/sub-8109/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8109	P2	HI1	HI2	${workDir}/sub-8109/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8109	P2	HI1	LO2	${workDir}/sub-8109/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8109	P2	LO1	HI2	${workDir}/sub-8109/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8109	P2	LO1	LO2	${workDir}/sub-8109/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8110	P1	HI1	HI2	${workDir}/sub-8110/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8110	P1	HI1	LO2	${workDir}/sub-8110/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8110	P1	LO1	HI2	${workDir}/sub-8110/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8110	P1	LO1	LO2	${workDir}/sub-8110/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8110	P2	HI1	HI2	${workDir}/sub-8110/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8110	P2	HI1	LO2	${workDir}/sub-8110/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8110	P2	LO1	HI2	${workDir}/sub-8110/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8110	P2	LO1	LO2	${workDir}/sub-8110/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8111	P1	HI1	HI2	${workDir}/sub-8111/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8111	P1	HI1	LO2	${workDir}/sub-8111/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8111	P1	LO1	HI2	${workDir}/sub-8111/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8111	P1	LO1	LO2	${workDir}/sub-8111/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8111	P2	HI1	HI2	${workDir}/sub-8111/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8111	P2	HI1	LO2	${workDir}/sub-8111/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8111	P2	LO1	HI2	${workDir}/sub-8111/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8111	P2	LO1	LO2	${workDir}/sub-8111/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8112	P1	HI1	HI2	${workDir}/sub-8112/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8112	P1	HI1	LO2	${workDir}/sub-8112/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8112	P1	LO1	HI2	${workDir}/sub-8112/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8112	P1	LO1	LO2	${workDir}/sub-8112/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8112	P2	HI1	HI2	${workDir}/sub-8112/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8112	P2	HI1	LO2	${workDir}/sub-8112/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8112	P2	LO1	HI2	${workDir}/sub-8112/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8112	P2	LO1	LO2	${workDir}/sub-8112/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8113	P1	HI1	HI2	${workDir}/sub-8113/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8113	P1	HI1	LO2	${workDir}/sub-8113/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8113	P1	LO1	HI2	${workDir}/sub-8113/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8113	P1	LO1	LO2	${workDir}/sub-8113/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8113	P2	HI1	HI2	${workDir}/sub-8113/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8113	P2	HI1	LO2	${workDir}/sub-8113/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8113	P2	LO1	HI2	${workDir}/sub-8113/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8113	P2	LO1	LO2	${workDir}/sub-8113/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8114	P1	HI1	HI2	${workDir}/sub-8114/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8114	P1	HI1	LO2	${workDir}/sub-8114/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8114	P1	LO1	HI2	${workDir}/sub-8114/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8114	P1	LO1	LO2	${workDir}/sub-8114/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8114	P2	HI1	HI2	${workDir}/sub-8114/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8114	P2	HI1	LO2	${workDir}/sub-8114/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8114	P2	LO1	HI2	${workDir}/sub-8114/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8114	P2	LO1	LO2	${workDir}/sub-8114/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8115	P1	HI1	HI2	${workDir}/sub-8115/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8115	P1	HI1	LO2	${workDir}/sub-8115/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8115	P1	LO1	HI2	${workDir}/sub-8115/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8115	P1	LO1	LO2	${workDir}/sub-8115/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8115	P2	HI1	HI2	${workDir}/sub-8115/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8115	P2	HI1	LO2	${workDir}/sub-8115/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8115	P2	LO1	HI2	${workDir}/sub-8115/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8115	P2	LO1	LO2	${workDir}/sub-8115/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8116	P1	HI1	HI2	${workDir}/sub-8116/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8116	P1	HI1	LO2	${workDir}/sub-8116/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8116	P1	LO1	HI2	${workDir}/sub-8116/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8116	P1	LO1	LO2	${workDir}/sub-8116/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8116	P2	HI1	HI2	${workDir}/sub-8116/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8116	P2	HI1	LO2	${workDir}/sub-8116/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8116	P2	LO1	HI2	${workDir}/sub-8116/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8116	P2	LO1	LO2	${workDir}/sub-8116/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8117	P1	HI1	HI2	${workDir}/sub-8117/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8117	P1	HI1	LO2	${workDir}/sub-8117/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8117	P1	LO1	HI2	${workDir}/sub-8117/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8117	P1	LO1	LO2	${workDir}/sub-8117/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8117	P2	HI1	HI2	${workDir}/sub-8117/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8117	P2	HI1	LO2	${workDir}/sub-8117/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8117	P2	LO1	HI2	${workDir}/sub-8117/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8117	P2	LO1	LO2	${workDir}/sub-8117/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8118	P1	HI1	HI2	${workDir}/sub-8118/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8118	P1	HI1	LO2	${workDir}/sub-8118/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8118	P1	LO1	HI2	${workDir}/sub-8118/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8118	P1	LO1	LO2	${workDir}/sub-8118/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8118	P2	HI1	HI2	${workDir}/sub-8118/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8118	P2	HI1	LO2	${workDir}/sub-8118/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8118	P2	LO1	HI2	${workDir}/sub-8118/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8118	P2	LO1	LO2	${workDir}/sub-8118/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8119	P1	HI1	HI2	${workDir}/sub-8119/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8119	P1	HI1	LO2	${workDir}/sub-8119/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8119	P1	LO1	HI2	${workDir}/sub-8119/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8119	P1	LO1	LO2	${workDir}/sub-8119/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8119	P2	HI1	HI2	${workDir}/sub-8119/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8119	P2	HI1	LO2	${workDir}/sub-8119/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8119	P2	LO1	HI2	${workDir}/sub-8119/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8119	P2	LO1	LO2	${workDir}/sub-8119/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8120	P1	HI1	HI2	${workDir}/sub-8120/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8120	P1	HI1	LO2	${workDir}/sub-8120/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8120	P1	LO1	HI2	${workDir}/sub-8120/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8120	P1	LO1	LO2	${workDir}/sub-8120/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8120	P2	HI1	HI2	${workDir}/sub-8120/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8120	P2	HI1	LO2	${workDir}/sub-8120/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8120	P2	LO1	HI2	${workDir}/sub-8120/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8120	P2	LO1	LO2	${workDir}/sub-8120/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8121	P1	HI1	HI2	${workDir}/sub-8121/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8121	P1	HI1	LO2	${workDir}/sub-8121/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8121	P1	LO1	HI2	${workDir}/sub-8121/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8121	P1	LO1	LO2	${workDir}/sub-8121/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8121	P2	HI1	HI2	${workDir}/sub-8121/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8121	P2	HI1	LO2	${workDir}/sub-8121/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8121	P2	LO1	HI2	${workDir}/sub-8121/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8121	P2	LO1	LO2	${workDir}/sub-8121/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8122	P1	HI1	HI2	${workDir}/sub-8122/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8122	P1	HI1	LO2	${workDir}/sub-8122/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8122	P1	LO1	HI2	${workDir}/sub-8122/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8122	P1	LO1	LO2	${workDir}/sub-8122/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8122	P2	HI1	HI2	${workDir}/sub-8122/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8122	P2	HI1	LO2	${workDir}/sub-8122/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8122	P2	LO1	HI2	${workDir}/sub-8122/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8122	P2	LO1	LO2	${workDir}/sub-8122/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8123	P1	HI1	HI2	${workDir}/sub-8123/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8123	P1	HI1	LO2	${workDir}/sub-8123/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8123	P1	LO1	HI2	${workDir}/sub-8123/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8123	P1	LO1	LO2	${workDir}/sub-8123/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8123	P2	HI1	HI2	${workDir}/sub-8123/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8123	P2	HI1	LO2	${workDir}/sub-8123/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8123	P2	LO1	HI2	${workDir}/sub-8123/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8123	P2	LO1	LO2	${workDir}/sub-8123/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8124	P1	HI1	HI2	${workDir}/sub-8124/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8124	P1	HI1	LO2	${workDir}/sub-8124/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8124	P1	LO1	HI2	${workDir}/sub-8124/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8124	P1	LO1	LO2	${workDir}/sub-8124/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8124	P2	HI1	HI2	${workDir}/sub-8124/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8124	P2	HI1	LO2	${workDir}/sub-8124/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8124	P2	LO1	HI2	${workDir}/sub-8124/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8124	P2	LO1	LO2	${workDir}/sub-8124/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8125	P1	HI1	HI2	${workDir}/sub-8125/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8125	P1	HI1	LO2	${workDir}/sub-8125/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8125	P1	LO1	HI2	${workDir}/sub-8125/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8125	P1	LO1	LO2	${workDir}/sub-8125/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8125	P2	HI1	HI2	${workDir}/sub-8125/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8125	P2	HI1	LO2	${workDir}/sub-8125/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8125	P2	LO1	HI2	${workDir}/sub-8125/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8125	P2	LO1	LO2	${workDir}/sub-8125/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8126	P1	HI1	HI2	${workDir}/sub-8126/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8126	P1	HI1	LO2	${workDir}/sub-8126/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8126	P1	LO1	HI2	${workDir}/sub-8126/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8126	P1	LO1	LO2	${workDir}/sub-8126/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8126	P2	HI1	HI2	${workDir}/sub-8126/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8126	P2	HI1	LO2	${workDir}/sub-8126/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8126	P2	LO1	HI2	${workDir}/sub-8126/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8126	P2	LO1	LO2	${workDir}/sub-8126/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8127	P1	HI1	HI2	${workDir}/sub-8127/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8127	P1	HI1	LO2	${workDir}/sub-8127/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8127	P1	LO1	HI2	${workDir}/sub-8127/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8127	P1	LO1	LO2	${workDir}/sub-8127/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8127	P2	HI1	HI2	${workDir}/sub-8127/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8127	P2	HI1	LO2	${workDir}/sub-8127/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8127	P2	LO1	HI2	${workDir}/sub-8127/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8127	P2	LO1	LO2	${workDir}/sub-8127/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8128	P1	HI1	HI2	${workDir}/sub-8128/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8128	P1	HI1	LO2	${workDir}/sub-8128/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8128	P1	LO1	HI2	${workDir}/sub-8128/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8128	P1	LO1	LO2	${workDir}/sub-8128/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8128	P2	HI1	HI2	${workDir}/sub-8128/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8128	P2	HI1	LO2	${workDir}/sub-8128/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8128	P2	LO1	HI2	${workDir}/sub-8128/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8128	P2	LO1	LO2	${workDir}/sub-8128/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8129	P1	HI1	HI2	${workDir}/sub-8129/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8129	P1	HI1	LO2	${workDir}/sub-8129/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8129	P1	LO1	HI2	${workDir}/sub-8129/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8129	P1	LO1	LO2	${workDir}/sub-8129/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8129	P2	HI1	HI2	${workDir}/sub-8129/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8129	P2	HI1	LO2	${workDir}/sub-8129/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8129	P2	LO1	HI2	${workDir}/sub-8129/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8129	P2	LO1	LO2	${workDir}/sub-8129/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8130	P1	HI1	HI2	${workDir}/sub-8130/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8130	P1	HI1	LO2	${workDir}/sub-8130/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8130	P1	LO1	HI2	${workDir}/sub-8130/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8130	P1	LO1	LO2	${workDir}/sub-8130/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8130	P2	HI1	HI2	${workDir}/sub-8130/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8130	P2	HI1	LO2	${workDir}/sub-8130/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8130	P2	LO1	HI2	${workDir}/sub-8130/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8130	P2	LO1	LO2	${workDir}/sub-8130/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8131	P1	HI1	HI2	${workDir}/sub-8131/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8131	P1	HI1	LO2	${workDir}/sub-8131/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8131	P1	LO1	HI2	${workDir}/sub-8131/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8131	P1	LO1	LO2	${workDir}/sub-8131/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8131	P2	HI1	HI2	${workDir}/sub-8131/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8131	P2	HI1	LO2	${workDir}/sub-8131/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8131	P2	LO1	HI2	${workDir}/sub-8131/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8131	P2	LO1	LO2	${workDir}/sub-8131/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8132	P1	HI1	HI2	${workDir}/sub-8132/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8132	P1	HI1	LO2	${workDir}/sub-8132/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8132	P1	LO1	HI2	${workDir}/sub-8132/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8132	P1	LO1	LO2	${workDir}/sub-8132/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8132	P2	HI1	HI2	${workDir}/sub-8132/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8132	P2	HI1	LO2	${workDir}/sub-8132/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8132	P2	LO1	HI2	${workDir}/sub-8132/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8132	P2	LO1	LO2	${workDir}/sub-8132/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8133	P1	HI1	HI2	${workDir}/sub-8133/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8133	P1	HI1	LO2	${workDir}/sub-8133/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8133	P1	LO1	HI2	${workDir}/sub-8133/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8133	P1	LO1	LO2	${workDir}/sub-8133/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8133	P2	HI1	HI2	${workDir}/sub-8133/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8133	P2	HI1	LO2	${workDir}/sub-8133/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8133	P2	LO1	HI2	${workDir}/sub-8133/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8133	P2	LO1	LO2	${workDir}/sub-8133/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8134	P1	HI1	HI2	${workDir}/sub-8134/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8134	P1	HI1	LO2	${workDir}/sub-8134/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8134	P1	LO1	HI2	${workDir}/sub-8134/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8134	P1	LO1	LO2	${workDir}/sub-8134/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8134	P2	HI1	HI2	${workDir}/sub-8134/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8134	P2	HI1	LO2	${workDir}/sub-8134/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8134	P2	LO1	HI2	${workDir}/sub-8134/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8134	P2	LO1	LO2	${workDir}/sub-8134/${deconvFile}_stats_blur${blurInt}+tlrc'[9]' \
 sub-8135	P1	HI1	HI2	${workDir}/sub-8135/${deconvFile}_stats_blur${blurInt}+tlrc'[0]' \
 sub-8135	P1	HI1	LO2	${workDir}/sub-8135/${deconvFile}_stats_blur${blurInt}+tlrc'[1]' \
 sub-8135	P1	LO1	HI2	${workDir}/sub-8135/${deconvFile}_stats_blur${blurInt}+tlrc'[2]' \
 sub-8135	P1	LO1	LO2	${workDir}/sub-8135/${deconvFile}_stats_blur${blurInt}+tlrc'[3]' \
 sub-8135	P2	HI1	HI2	${workDir}/sub-8135/${deconvFile}_stats_blur${blurInt}+tlrc'[6]' \
 sub-8135	P2	HI1	LO2	${workDir}/sub-8135/${deconvFile}_stats_blur${blurInt}+tlrc'[7]' \
 sub-8135	P2	LO1	HI2	${workDir}/sub-8135/${deconvFile}_stats_blur${blurInt}+tlrc'[8]' \
 sub-8135	P2	LO1	LO2	${workDir}/sub-8135/${deconvFile}_stats_blur${blurInt}+tlrc'[9]'
