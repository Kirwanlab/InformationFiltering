#!/bin/bash

#SBATCH --time=30:00:00   # walltime
#SBATCH --ntasks=6   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=8gb   # memory per CPU core
#SBATCH -J "TaskS2"   # job name

# Compatibility variables for PBS. Delete if not needed.
export PBS_NODEFILE=`/fslapps/fslutils/generate_pbs_nodefile`
export PBS_JOBID=$SLURM_JOB_ID
export PBS_O_WORKDIR="$SLURM_SUBMIT_DIR"
export PBS_QUEUE=batch

# Set the max number of threads to use for programs using OpenMP. Should be <= ppn. Does nothing if the program doesn't use OpenMP.
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE




# Written by Nathan Muncy on 10/24/18


### --- Notes
#
# 1) Will do deconvolutions (OLS, GLS), post files, and print out info
#
# 2) Can do a variable number of deconvolutions for each phase of the experiment
#		generates the scripts, and then runs them - turn off $runDecons for simple script generation
#
# 3) Assumes timing files exist in derivatives/sub-123/timing_files, and are in .1D format
#
# 4) Only the variables at the beginning of the script need to be updated (this is NEW and COOL)




subj=$1
testMode=$2


													###??? update these variables/arrays - NEW: only this section needs to be updated!
parDir=~/compute/KnowFiltMISQ				  			# parent dir, where derivatives is located
workDir=${parDir}/derivatives/$subj

doREML=1											# conduct GLS decon (1=on), runDecons must be 1
runDecons=1											# toggle for running decon/reml scripts and post hoc (1=on)
deconNum=(1)										# number of planned decons per PHASE, corresponds to $phaseArr from step1 (STUDY TEST1 TEST2). E.g. (2 1 1) = the first phase will have 2 deconvolutions, and the second and third phase will both have 1 respectively
deconLen=(2.5)										# trial duration for each Phase (argument for BLOCK in deconvolution)
deconPref=(knowfilt2)				            			# array of prefix for each planned decon (length must equal sum of $deconNum)



### --- Set up --- ###
#
# Determine number of phases, and number of blocks per phase
# then set these as arrays. Set up decon arrays.
# Check the deconvolution variables are set up correctly


# determine num phases/blocks
cd $workDir

> tmp.txt
for i in run*scale+tlrc.HEAD; do

	tmp=${i%_*}
	run=${i%%_*}
	phase=${tmp#*_}

	echo -e "$run \t $phase" >> tmp.txt
done

awk -F '\t' '{print $2}' tmp.txt | sort | uniq -c > phase_list.txt
rm tmp.txt


blockArr=(`cat phase_list.txt | awk '{print $1}'`)
phaseArr=(`cat phase_list.txt | awk '{print $2}'`)
phaseLen=${#phaseArr[@]}




### --- Motion --- ###
#
# motion and censor files are constructed. Multiple motion files
# include mean and derivative of motion.


phase=knowfilt
nruns=2

cat dfile.run-*${phase}.1D > dfile_rall_${phase}.1D
if [ ! -s censor_${phase}_combined.1D ]; then

    # files: de-meaned, motion params (per phase)
    1d_tool.py -infile dfile_rall_${phase}.1D -set_nruns $nruns -demean -write motion_demean_${phase}.1D
    1d_tool.py -infile dfile_rall_${phase}.1D -set_nruns $nruns -derivative -demean -write motion_deriv_${phase}.1D
    1d_tool.py -infile motion_demean_${phase}.1D -set_nruns $nruns -split_into_pad_runs mot_demean_${phase}
    1d_tool.py -infile dfile_rall_${phase}.1D -set_nruns $nruns -show_censor_count -censor_prev_TR -censor_motion 0.3 motion_${phase}


    # determine censor
    cat out.cen.run-*${phase}.1D > outcount_censor_${phase}.1D
    1deval -a motion_${phase}_censor.1D -b outcount_censor_${phase}.1D -expr "a*b" > censor_${phase}_combined.1D
fi




### --- Deconvolve --- ###
#
# A deconvolution (OLS) script is written (for review) and then run.
# Currently, behaviors are called beh_1, beh_2 etc due to practical
# constraints. I'll probably fix this in the future. A deconv script
# is written for each run of the experiment, and for different
# phases a conditional allows control over things like timing
# files and different block times. Timing files are not constructed.
# A REML (GLS) script is written, for future use.

## Need to update:
3dDeconvolve -input run-01_knowfilt_scale+tlrc run-02_knowfilt_scale+tlrc \
     -censor censor_${phase}_combined.1D \
     -polort A -float \
     -num_stimts 21 \
     -stim_file 1 mot_demean_${phase}.r01.1D'[0]' -stim_base 1 -stim_label 1 mot_1.1 \
     -stim_file 2 mot_demean_${phase}.r01.1D'[1]' -stim_base 2 -stim_label 2 mot_2.1 \
     -stim_file 3 mot_demean_${phase}.r01.1D'[2]' -stim_base 3 -stim_label 3 mot_3.1 \
     -stim_file 4 mot_demean_${phase}.r01.1D'[3]' -stim_base 4 -stim_label 4 mot_4.1 \
     -stim_file 5 mot_demean_${phase}.r01.1D'[4]' -stim_base 5 -stim_label 5 mot_5.1 \
     -stim_file 6 mot_demean_${phase}.r01.1D'[5]' -stim_base 6 -stim_label 6 mot_6.1 \
     -stim_file 7 mot_demean_${phase}.r02.1D'[0]' -stim_base 7 -stim_label 7 mot_1.2 \
     -stim_file 8 mot_demean_${phase}.r02.1D'[1]' -stim_base 8 -stim_label 8 mot_2.2 \
     -stim_file 9 mot_demean_${phase}.r02.1D'[2]' -stim_base 9 -stim_label 9 mot_3.2 \
     -stim_file 10 mot_demean_${phase}.r02.1D'[3]' -stim_base 10 -stim_label 10 mot_4.2 \
     -stim_file 11 mot_demean_${phase}.r02.1D'[4]' -stim_base 11 -stim_label 11 mot_5.2 \
     -stim_file 12 mot_demean_${phase}.r02.1D'[5]' -stim_base 12 -stim_label 12 mot_6.2 \
     -stim_times_AM1 13 timings/Phase_1_all.txt 'dmBLOCK' -stim_label 13 p1all \
     -stim_times_AM1 14 timings/Phase_2_HHL.txt 'dmBLOCK' -stim_label 14 HHL \
     -stim_times_AM1 15 timings/Phase_2_LLH.txt 'dmBLOCK' -stim_label 15 LLH \
     -stim_times_AM1 16 timings/Phase_2_HLH.txt 'dmBLOCK' -stim_label 16 HLH \
     -stim_times_AM1 17 timings/Phase_2_HLL.txt 'dmBLOCK' -stim_label 17 HLL \
     -stim_times_AM1 18 timings/Phase_2_LHH.txt 'dmBLOCK' -stim_label 18 LHH \
     -stim_times_AM1 19 timings/Phase_2_LHL.txt 'dmBLOCK' -stim_label 19 LHL \
     -stim_times_AM1 20 timings/Phase_2_HHH.txt 'dmBLOCK' -stim_label 20 HHH \
     -stim_times_AM1 21 timings/Phase_2_LLL.txt 'dmBLOCK' -stim_label 21 LLL \
     -noFDR -nofullf_atall \
     -x1D X.${deconPref}.xmat.1D \
     -xjpeg X.${deconPref}.jpg \
     -x1D_uncensored X.${deconPref}.nocensor.xmat.1D \
     -errts ${deconPref}_errts \
     -bucket ${deconPref}_stats \
     -jobs 6 \
     -GOFORIT 12



#### --- REML and Post Calcs --- ###
#
# REML deconvolution (GLS) is run, excluding WM signal. REML will
# probably become standard soon, so I'll get this working at some point.
# Global SNR and corr are calculated.


c=0; count=0; while [ $c -lt $phaseLen ]; do


	# loop through number of planned decons, set arr
	phase=${phaseArr[$c]}

	numD=${deconNum[$c]}
	x=0; for((i=1; i<=$numD; i++)); do

		regArr[$x]=${deconPref[$count]}

		let x=$[$x+1]
		let count=$[$count+1]
	done


	# all runs signal
	countS=`1d_tool.py -infile censor_${phase}_combined.1D -show_trs_uncensored encoded`

	if [ ! -f ${regArr[0]}_TSNR+tlrc.HEAD ]; then
		3dTcat -prefix tmp_${phase}_all_runs run-*${phase}_scale+tlrc.HEAD
		3dTstat -mean -prefix tmp_${phase}_allSignal tmp_${phase}_all_runs+tlrc"[${countS}]"
	fi


	# timeseries of eroded WM
	if [ $doREML == 1 ]; then
		if [ ! -f ${phase}_WMe_rall+tlrc.HEAD ]; then

			3dTcat -prefix tmp_allRuns_${phase} run-*${phase}_volreg_clean+tlrc.HEAD
			3dcalc -a tmp_allRuns_${phase}+tlrc -b final_mask_WM_eroded+tlrc -expr "a*bool(b)" -datum float -prefix tmp_allRuns_${phase}_WMe
			3dmerge -1blur_fwhm 20 -doall -prefix ${phase}_WMe_rall tmp_allRuns_${phase}_WMe+tlrc
		fi
	fi


	for j in ${regArr[@]}; do

		# kill if decon failed
		if [ $runDecons == 1 ]; then
			if [ ! -f ${j}_stats+tlrc.HEAD ]; then
				echo "" >&2
				echo "Decon failed on $j ... Exit 5" >&2
				echo "" >&2
				exit 5
			fi
		fi


		if [ $runDecons == 1 ]; then
			if [ $doREML == 1 ]; then

				# REML
				if [ ! -f ${j}_stats_REML+tlrc.HEAD ]; then
					tcsh -x ${j}_stats.REML_cmd -dsort ${phase}_WMe_rall+tlrc
				fi


				# kill if REMl failed
				if [ ! -f ${j}_stats_REML+tlrc.HEAD ]; then
					echo "" >&2
					echo "REML failed on $j ... Exit 6" >&2
					echo "" >&2
					exit 6
				fi


				# calc SNR, corr
				if [ ! -f ${j}_TSNR+tlrc.HEAD ]; then

					3dTstat -stdev -prefix tmp_${j}_allNoise ${j}_errts_REML+tlrc"[${countS}]"

					3dcalc -a tmp_${phase}_allSignal+tlrc \
					-b tmp_${j}_allNoise+tlrc \
					-c full_mask+tlrc \
					-expr 'c*a/b' -prefix ${j}_TSNR

					3dTnorm -norm2 -prefix tmp_${j}_errts_unit ${j}_errts_REML+tlrc
					3dmaskave -quiet -mask full_mask+tlrc tmp_${j}_errts_unit+tlrc > ${j}_gmean_errts_unit.1D
					3dcalc -a tmp_${j}_errts_unit+tlrc -b ${j}_gmean_errts_unit.1D -expr 'a*b' -prefix tmp_${j}_DP
					3dTstat -sum -prefix ${j}_corr_brain tmp_${j}_DP+tlrc
				fi
			fi
		fi


		# detect pairwise cor
		1d_tool.py -show_cormat_warnings -infile X.${j}.xmat.1D | tee out.${j}.cormat_warn.txt
	done
	let c=$[$c+1]
done



for i in ${deconPref[@]}; do

	# sum of regressors, stim only x-matrix
	if [ ! -s X.${i}.stim.xmat.1D ]; then

		reg_cols=`1d_tool.py -infile X.${i}.nocensor.xmat.1D -show_indices_interest`
		3dTstat -sum -prefix ${i}_sum_ideal.1D X.${i}.nocensor.xmat.1D"[$reg_cols]"
		1dcat X.${i}.nocensor.xmat.1D"[$reg_cols]" > X.${i}.stim.xmat.1D
	fi
done




#### --- Print out info, Clean --- ###
#
# Print out information about the data - of particulatr interest
# is the number of TRs censored, which steps3/4 use. This involves
# producing the needed files, generating a set of review scripts,
# and then running my favorite. Many intermediates get removed.


# organize files for what gen*py needs
3dcopy full_mask+tlrc full_mask.${subj}+tlrc

if [ $runDecons == 1 ]; then
	for i in ${phaseArr[@]}; do

		cat outcount.run-*${i}.1D > outcount_all_${i}.1D

		c=1; for j in run-*${i}*+orig.HEAD; do

			prefix=${j%+*}
			3dcopy ${j%.*} pb00.${subj}.r0${c}.tcat
			3dcopy ${prefix}_volreg_clean+tlrc pb02.${subj}.r0${c}.volreg

			let c=$[$c+1]
		done


		for k in ${deconPref[@]}; do

			# a touch more organization (gen*py is very needy)
			dset=${k}_stats+tlrc
			cp X.${k}.xmat.1D X.xmat.1D
			3dcopy ${k}_errts+tlrc errts.${subj}+tlrc


			# generate script
			gen_ss_review_scripts.py \
			-subj ${subj} \
			-rm_trs 0 \
			-motion_dset dfile_rall_${i}.1D \
			-outlier_dset outcount_all_${i}.1D \
			-enorm_dset  motion_${i}_enorm.1D \
			-mot_limit 0.3 \
			-out_limit 0.1 \
			-xmat_regress X.${k}.xmat.1D \
			-xmat_uncensored X.${k}.nocensor.xmat.1D \
			-stats_dset ${dset} \
			-final_anat final_anat+tlrc \
			-final_view tlrc \
			-exit0


			# run script - write an output for e/analysis
			./\@ss_review_basic | tee out_summary_${k}.txt


			# clean
			rm errts.*
			rm X.xmat.1D
			rm pb0*
			rm *ss_review*
		done
	done
fi



## clean
if [ $testMode == 1 ]; then
   rm tmp_*
   rm -r awpy
   rm anat.un.aff*
   rm final_mask_{CSF,GM}*
   rm *corr_brain*
   rm *gmean_errts*
   rm *volreg*
   rm Temp*
   rm *WMe_rall*
   rm full_mask.*
fi
