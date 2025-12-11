#!/bin/bash
#$ -pe mpi 12
#$ -cwd
#$ -j y
#$ -S /bin/bash

echo "====== Starting ALL Quantum ESPRESSO steps ======"

WORKDIR=$PWD
SCRATCH=/state/partition1/$USER/$JOB_ID
mkdir -p $SCRATCH
cd $SCRATCH

module load qe/7.1_intel
source /share/apps/intel/oneapi/setvars.sh
export OMPI_MCA_btl=vader,self,tcp

echo "====== COPYING INPUTS AND PSEUDOS ======"
cp $WORKDIR/*.in .
cp $WORKDIR/*.UPF .

#########################################
# 1) SCF
#########################################

echo "====== RUNNING SCF ======"
mpirun pw.x < scf.in > scf.out
cp -r tmp2 $WORKDIR/
cp -r *.save $WORKDIR/
cp scf.out $WORKDIR/

#########################################
# 2) NSCF
#########################################

echo "====== RUNNING NSCF ======"
cp $WORKDIR/nscf.in .
cp -r $WORKDIR/tmp2 ./
cp -r $WORKDIR/*.save ./

mpirun pw.x < nscf.in > nscf.out
cp -r tmp2 $WORKDIR/
cp -r *.save $WORKDIR/
cp nscf.out $WORKDIR/

#########################################
# 3) BANDS
#########################################

echo "====== RUNNING BANDS ======"
cp $WORKDIR/bands.in .
cp $WORKDIR/bands_pp.in .
cp -r $WORKDIR/tmp2 ./
cp -r $WORKDIR/*.save ./

mpirun pw.x < bands.in > bands.out
bands.x < bands_pp.in > bands_pp.out

cp -r tmp2 $WORKDIR/
cp -r *.save $WORKDIR/
cp bands.out bands_pp.out $WORKDIR/

#########################################
# 4) DOS
#########################################

echo "====== RUNNING DOS ======"
cp $WORKDIR/dos.in .
cp -r $WORKDIR/tmp2 ./
cp -r $WORKDIR/*.save ./

dos.x < dos.in > dos.out

cp -r tmp2 $WORKDIR/
cp dos.out $WORKDIR/

#########################################
# 5) PDOS
#########################################

echo "====== RUNNING PDOS ======"
cp $WORKDIR/pdos.in .
cp -r $WORKDIR/tmp2 ./
cp -r $WORKDIR/*.save ./

projwfc.x < pdos.in > pdos.out

cp -r tmp2 $WORKDIR/
cp pdos.out $WORKDIR/
cp *.pdos* $WORKDIR/

#########################################

echo "====== ALL QE STEPS COMPLETED SUCCESSFULLY ======"

cd $WORKDIR

