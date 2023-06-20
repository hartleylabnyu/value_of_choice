#!/bin/bash
#SBATCH --job-name=fit_sim_data_spaced
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=3GB
#SBATCH --time=4:00:00
#SBATCH --output=out_files/fit_data_spaced_%a.out
#SBATCH --array=1-1000

sim_num=$SLURM_ARRAY_TASK_ID

module purge
module load matlab/2020b
 
cd /scratch/projects/hartleylab/VoC
 
echo "Job starts: $(date)"
echo "Hostname: $(hostname)"
 
cat<<EOF | matlab -nodisplay 

try
    fit_simulated_data_spaced($sim_num)
catch err
    fprintf('\n\nTime: %s\n', datestr(datetime('now')));
    fprintf('Matlab error: %s\n', err.message);
    exit(1);
end
EOF
 
matlab_status=$?
echo "Job ends: $(date)"
exit $matlab_status
