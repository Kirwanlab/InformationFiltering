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
    if [ ! -f allPhase2_stats+tlrc.HEAD ]; then
        3dDeconvolve -input run-01_knowfilt_scale+tlrc run-02_knowfilt_scale+tlrc \
             -censor censor_${phase}_combined.1D \
             -polort A -float \
             -num_stimts 13 \
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
             -stim_times_IM 13 timings/all_phase2_times.txt 'dmBLOCK(1)'   -stim_label 13 phase2 \
             -noFDR -nofullf_atall \
             -x1D X.allPhase2.xmat.1D \
             -xjpeg X.allPhase2.jpg \
             -x1D_uncensored X.allPhase2.nocensor.xmat.1D \
             -errts allPhase2_errts \
             -bucket allPhase2_stats \
             -jobs 6 \
             -GOFORIT 12
    fi


    #do the computations using 3dLSS, which uses Mumford's LSS method:
    if [ ! -f  allPhase2_LSS+tlrc.HEAD ]; then
        3dtcat -prefix run-all_knowfilt_scale run-01_knowfilt_scale+tlrc run-02_knowfilt_scale+tlrc

        3dLSS -matrix X.allPhase2.nocensor.xmat.1D \
             -mask full_mask+tlrc \
             -input run-all_knowfilt_scale+tlrc \
             -prefix allPhase2_LSS \
             -save1D allPhase2_LSS.1D \
             -verb
    fi

    cd $derDir

done

