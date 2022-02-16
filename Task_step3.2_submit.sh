#!/bin/bash




###??? update these
parDir=~/compute/KnowFiltMISQ				  			# parent dir, where derivatives is located
workDir=${parDir}/derivatives
scriptDir=${parDir}/code
slurmDir=${workDir}/Slurm_out

time=`date '+%Y_%m_%d-%H_%M_%S'`
outDir=${slurmDir}/TaskStep3_${time}

mkdir -p $outDir

cd $workDir
for i in sub*; do

    sbatch \
    -o ${outDir}/output_TaskN3_${i}.txt \
    -e ${outDir}/error_TaskN3_${i}.txt \
    ${scriptDir}/Task_step3.2_deconvolve.sh $i

    sleep 1
done
