#!/bin/bash

parDir=/Volumes/Yorick/ZZ_Archive/KnowFiltMISQ                              # parent dir, where derivatives is located
derDir=${parDir}/derivatives


cd $derDir

for i in sub*; do

    cd $i

    ### --- Motion --- ###
    #
    # motion and censor files are constructed. Multiple motion files
    # include mean and derivative of motion.

    # # Do I need to do this again?

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

    # Taken from Adaptation Study:
    if [ ! -f deconv_phase1_stats+tlrc.HEAD ]; then
        3dDeconvolve -input run-01_knowfilt_scale+tlrc run-02_knowfilt_scale+tlrc \
             -censor censor_${phase}_combined.1D \
             -polort A -float \
             -num_stimts 26 \
             -stim_file 1 mot_demean_${phase}.r01.1D'[0]' -stim_base 1 -stim_label 1 mot_1r1 \
             -stim_file 2 mot_demean_${phase}.r01.1D'[1]' -stim_base 2 -stim_label 2 mot_2r1 \
             -stim_file 3 mot_demean_${phase}.r01.1D'[2]' -stim_base 3 -stim_label 3 mot_3r1 \
             -stim_file 4 mot_demean_${phase}.r01.1D'[3]' -stim_base 4 -stim_label 4 mot_4r1 \
             -stim_file 5 mot_demean_${phase}.r01.1D'[4]' -stim_base 5 -stim_label 5 mot_5r1 \
             -stim_file 6 mot_demean_${phase}.r01.1D'[5]' -stim_base 6 -stim_label 6 mot_6r1 \
             -stim_file 7 mot_demean_${phase}.r02.1D'[0]' -stim_base 7 -stim_label 7 mot_1r2 \
             -stim_file 8 mot_demean_${phase}.r02.1D'[1]' -stim_base 8 -stim_label 8 mot_2r2 \
             -stim_file 9 mot_demean_${phase}.r02.1D'[2]' -stim_base 9 -stim_label 9 mot_3r2 \
             -stim_file 10 mot_demean_${phase}.r02.1D'[3]' -stim_base 10 -stim_label 10 mot_4r2 \
             -stim_file 11 mot_demean_${phase}.r02.1D'[4]' -stim_base 11 -stim_label 11 mot_5r2 \
             -stim_file 12 mot_demean_${phase}.r02.1D'[5]' -stim_base 12 -stim_label 12 mot_6r2 \
			 -stim_times_AM1 13 timings/Phase_1_HHH.txt 'dmBLOCK' -stim_label 13  "P1HHH" \
			 -stim_times_AM1 14 timings/Phase_1_HHL.txt 'dmBLOCK' -stim_label 14  "P1HHL" \
			 -stim_times_AM1 15 timings/Phase_1_LLH.txt 'dmBLOCK' -stim_label 15  "P1LLH" \
			 -stim_times_AM1 16 timings/Phase_1_LLL.txt 'dmBLOCK' -stim_label 16  "P1LLL" \
			 -stim_times_AM1 17 timings/Phase_1_HL.txt  'dmBLOCK' -stim_label 17  "xP1HL" \
			 -stim_times_AM1 18 timings/Phase_1_LH.txt  'dmBLOCK' -stim_label 18  "xP1LH" \
			 -stim_times_AM1 19 timings/Phase_2_HHH.txt 'dmBLOCK' -stim_label 19  "P2HHH" \
			 -stim_times_AM1 20 timings/Phase_2_HHL.txt 'dmBLOCK' -stim_label 20  "P2HHL" \
			 -stim_times_AM1 21 timings/Phase_2_LLH.txt 'dmBLOCK' -stim_label 21  "P2LLH" \
			 -stim_times_AM1 22 timings/Phase_2_LLL.txt 'dmBLOCK' -stim_label 22  "P2LLL" \
			 -stim_times_AM1 23 timings/Phase_2_HLH.txt 'dmBLOCK' -stim_label 23  "xP2HLH" \
			 -stim_times_AM1 24 timings/Phase_2_HLL.txt 'dmBLOCK' -stim_label 24  "xP2HLL" \
			 -stim_times_AM1 25 timings/Phase_2_LHH.txt 'dmBLOCK' -stim_label 25  "xP2LHH" \
			 -stim_times_AM1 26 timings/Phase_2_LHL.txt 'dmBLOCK' -stim_label 26  "xP2LHL" \
			 -noFDR -nofullf_atall \
             -x1D X.deconv_phase1.xmat.1D \
             -xjpeg X.deconv_phase1.jpg \
             -x1D_uncensored X.deconv_phase1.nocensor.xmat.1D \
             -errts deconv_phase1_errts \
             -bucket deconv_phase1_stats \
             -jobs 6 \
             -GOFORIT 12
    fi

    cd $derDir

done

