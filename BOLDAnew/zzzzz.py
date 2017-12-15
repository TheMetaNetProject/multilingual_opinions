#!/usr/bin/env python
import subprocess
import time
import random

jobs = [720057, 720063, 727758, 727760, 727761, 727762, 727763, 727850, 727854, 727855, 727877, 727878, 720095, 720096, 720097, 720106, 720107, 720108, 720109, 720110, 720111, 734136, 734137, 734138, 734139, 734140, 734141]
 
for job in jobs:
    str1 = 'scancel '+str(job)
    print(str1)

time.sleep(59*60*8)
for job in jobs:
#    time.sleep(random.randint(2e2, 3e2))
    str1 = 'scancel '+str(job)
    subprocess.call(str1, shell=True)

#T = [20, 40, 60, 80, 101, 120]
#jobs = [
#'sbatch --mem 7000 -p vision BOLDArun.sh es verbadj 120 1 1',
#'sbatch --mem 7000 -p vision BOLDArun.sh es verbadj 120 3 1',
#'sbatch --mem 7000 -p vision BOLDArun2.sh es verbadj 140 1 1',
#'sbatch --mem 7000 -p vision BOLDArun2.sh es verbadj 140 2 1',
#'sbatch --mem 7000 -p vision BOLDArun2.sh es verbadj 140 3 1',
#'sbatch --mem 7000 -p vision BOLDArun2.sh es verbadj 140 4 1',
#]

#for i in range(8):
#    job = jobs[i]
#    subprocess.call(job, shell=True)

#time.sleep(36*60*60)

#for job in jobs:
#    time.sleep(random.randint(1e3, 2e3))
#    subprocess.call(job, shell=True)