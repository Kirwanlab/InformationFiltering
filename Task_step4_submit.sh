#!/bin/bash





workDir=~/compute/KnowFiltMISQ
scriptDir=${workDir}/code
slurmDir=${workDir}/derivatives/Slurm_out
time=`date '+%Y_%m_%d-%H_%M_%S'`
outDir=${slurmDir}/TaskS4_${time}

mkdir -p $outDir


sbatch \
-o ${outDir}/output_TaskS4.txt \
-e ${outDir}/error_TaskS4.txt \
${scriptDir}/Task_step4_grpAnalysis.sh
