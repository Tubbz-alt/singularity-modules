#!/bin/sh

IMAGE=/afs/slac/package/singularity/./images/imod/4.9.12/imod@4.9.12.sif
SINGULARITY=singularity
GPU=
LSF=
SLURM=

ENVFILE=`dirname "$0"`/../env
if [[ -L "${ENVFILE}" || -e "${ENVFILE}" ]]; then
  source ${ENVFILE}
fi

arch=$( /afs/slac/package/singularity/node_features.sh --no-gpu | grep 'CPU_GEN' )
fn=$(basename -- "$IMAGE")
image=${IMAGE%.*}^$arch.${fn##*.}
if [ -e "$image" ]; then
  IMAGE=$image
fi

MOUNTS=''
if [ -d /gpfs ]; then
  MOUNTS='/gpfs'
fi
if [ -d /sdf ]; then
  MOUNTS=$MOUNTS,/sdf
fi
if [ -d /nfs ]; then
  MOUNTS=$MOUNTS,/nfs
fi
if [ -d /scratch ]; then
  MOUNTS=$MOUNTS,/scratch
fi 
if [ -d /afs ]; then
  MOUNTS=$MOUNTS,/afs
fi
if [ -d /cvmfs ]; then
  MOUNTS=$MOUNTS,/cvmfs
fi

if [ "$LSF" == "1" ]; then
  LSF=" -B /afs/slac/package/lsf:/opt/lsf "
fi
if [ "$SLURM" == "1" ]; then
  if [ -e /var/run/munge/munge.socket.2 ]; then
  SLURM=" -B /opt/slurm,/var/run/munge/munge.socket.2:/mnt/munge.socket.2 "
  fi
fi

exec ${SINGULARITY} exec ${GPU} -B ${MOUNTS} ${LSF} ${SLURM} ${IMAGE} $(basename "$0")  "$@"
