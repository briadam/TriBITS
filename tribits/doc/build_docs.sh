#!/bin/bash -e

#
# Build all of the TriBITS-related documentation
#
# To build this documentation, just do:
#
#   cd <thisDir>
#   ./build_docs
#

_BASE_DIR=$PWD

echo
echo "***"
echo "*** Generating TribitsDevelopersGuide.[rst,html,pdf] ..."
echo "***"
echo

cd $_BASE_DIR/developers_guide
./generate-dev-guide.sh 
echo
echo "See generated files:"
echo
ls $_BASE_DIR/developers_guide/TribitsDevelopersGuide.*

echo
echo "***"
echo "*** Generating TribitsBuildQuickRef.[rst,html,pdf] ..."
echo "***"
echo

cd $_BASE_DIR/build_quick_ref
./create-build-quickref.sh  
echo
echo "See generated files:"
echo
ls $_BASE_DIR/build_quick_ref/TribitsBuildQuickRef.*

#echo
#echo "***"
#echo "*** Generating TribitsOverview.pdf ..."
#echo "***"
#echo
#
#cd $_BASE_DIR/overview
#source source_set_env 
#make
#echo
#echo "See generated files:"
#echo
#ls $_BASE_DIR/overview/TribitsOverview.pdf
#
#echo
#echo "***"
#echo "*** Generating TribitsLifecycleModel.pdf ..."
#echo "***"
#echo
#
#cd $_BASE_DIR/lifecycle_model
#make
#echo
#echo "See generated files:"
#echo
#ls $_BASE_DIR/lifecycle_model/TribitsLifecycleModel.pdf
