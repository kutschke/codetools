#!/bin/bash
# Ryunosuke O'Neil, 2020
# roneil@fnal.gov
# ryunosuke.oneil@postgrad.manchester.ac.uk


function do_setupstep() {
    source /cvmfs/fermilab.opensciencegrid.org/products/common/etc/setups
    setup mu2e
    setup codetools

    # building prof or debug
    ./buildopts --build="$BUILDTYPE"
    source setup.sh

    return 0
}

function do_buildstep() {
    scons --debug=time -k -j 24 2>&1 | tee "${WORKSPACE}/scons.log"
    return "${PIPESTATUS[0]}"
}

function do_runstep() {
    mu2e -n 10 -c Validation/fcl/ceSimReco.fcl 2>&1 | tee "${WORKSPACE}/ceSimReco.log"
    return "${PIPESTATUS[0]}"
}

function do_archivestep() {
    echo "[$(date)] Now gzip the compiled build, saving this for validation if needed."
    cd "$WORKSPACE" || exit
    tar -zcvf rev_"${COMMIT_SHA}"_pr_lib.tar.gz Offline/lib
}

# dump the rev
git show
git rev-parse HEAD

cd "$WORKSPACE" || exit
cd "$REPO" || exit

# dump the rev
git show
git rev-parse HEAD

echo "[$(date)] setup"

do_setupstep

echo "[$(date)] ups"
ups active

echo "[$(date)] build"
do_buildstep

SCONS_RC=$?
echo "[$(date)] scons return code is $SCONS_RC"

if [ $SCONS_RC -ne 0 ]; then
  exit 1
fi

echo "[$(date)] run test"
do_runstep

CESIMRECO_RC=$?
echo "[$(date)] ceSimReco return code is $CESIMRECO_RC"
if [ $CESIMRECO_RC -ne 0 ]; then
  exit 2
fi

do_archivestep
exit 0