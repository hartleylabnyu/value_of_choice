#!/bin/bash
#SBATCH --job-name=sim_data
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1GB
#SBATCH --time=0:10:00
#SBATCH --output=out_files/sim_data_%a.out
#SBATCH --array=1-1000

sim_num=$SLURM_ARRAY_TASK_ID

module purge
module load matlab/2020b
 
cd /scratch/projects/hartleylab/VoC
 
echo "Job starts: $(date)"
echo "Hostname: $(hostname)"
 
cat<<EOF | matlab -nodisplay 

try
    simulate_choice_data_randParams($sim_num);
catch err
    fprintf('\n\nTime: %s\n', datestr(datetime('now')));
    fprintf('Matlab error: %s\n', err.message);
    exit(1);
end
EOF
 
matlab_status=$?
echo "Job ends: $(date)"
exit $matlab_status
