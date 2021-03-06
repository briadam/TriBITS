# @HEADER
# ************************************************************************
#
#            TriBITS: Tribal Build, Integrate, and Test System
#                    Copyright 2013 Sandia Corporation
#
# Under the terms of Contract DE-AC04-94AL85000 with Sandia Corporation,
# the U.S. Government retains certain rights in this software.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the Corporation nor the names of the
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY SANDIA CORPORATION "AS IS" AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL SANDIA CORPORATION OR THE
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ************************************************************************
# @HEADER


INCLUDE(SetCacheOnOffEmpty)
INCLUDE(MultilineSet)
INCLUDE(AdvancedOption)
INCLUDE(AssertDefined)
INCLUDE(TribitsSortListAccordingToMasterList)


#
# @MACRO: TRIBITS_PROJECT_DEFINE_EXTRA_REPOSITORIES()
#
# Declare a set of extra repositories for the `TriBITS Project`_ (i.e. in the
# project's `<projectDir>/cmake/ExtraRepositoriesList.cmake`_ file).
#
# Usage::
#
#   TRIBITS_PROJECT_DEFINE_EXTRA_REPOSITORIES(
#     <repo0_name> <repo0_dir> <repo0_type> <repo0_url> <repo0_packstat> <repo0_classif>
#     <repo1_name> <repo1_dir> <repo1_type> <repo1_url> <rep10_packstat> <repo1_classif>
#     ...
#    )
#
# This macro takes in a 2D array with 6 columns, where each row defines an
# extra repository.  The 6 columns (ordered 0-5) are:
#
# 0. **REPO_NAME** (``<repoi_name>``): The name given to the repository
#    ``REPOSITORY_NAME``.
#
# 1. **REPO_DIR** (``<repoi_dir>``): The relative directory for the repository
#    under the project directory ``${PROJECT_SOURCE_DIR}`` (or
#    ``<projectDir>``).  If this is set to empty quoted string ``""``, then
#    the relative directory name is assumed to be same as the repository name
#    ``<repoi_name>``.
#
# 2. **REPO_TYPE** (``<repoi_type>``): The version control (VC) type of the
#    repo.  Value choices include ``GIT`` and ``SVN`` (i.e. Subversion).
#    *WARNING:* Only VC repos of type ``GIT`` can fully participate in the
#    TriBITS development tool workflows.  The other VC types are supported for
#    basic cloning and updating using `TRIBITS_CTEST_DRIVER()`_ script.
#
# 3. **REPO_URL** (``<repoi_url>``): The URL of the VC repo.  This info is
#    used to initially obtain the repo source code using the VC tool listed in
#    ``<repoi_type>``.  If the repos don't need to be cloned for the needed
#    use cases, then this can be the empty quoted string ``""``.
#
# 4. **REPO_PACKSTAT** (``<repoi_packstat>``): Determines if the VC repository
#    contains any TriBITS packages or if it just provides directories and
#    files.  If the VC repo contains TriBITS packages, then this field must be
#    the empty quoted string ``""``, and this repository is considered to be a
#    `TriBITS Repository`_ and must therefore contain the files described in
#    `TriBITS Repository Core Files`_.  If the listed repository is **not** a
#    TriBITS repository, and just provides directories and files, then this
#    field must be set as ``NOPACKAGES``.
#
# 5. **REPO_CLASSIFICATION** (``<repoi_classif>``): Gives the `Repository Test
#    Classification`_ also happens to be the CTest/CDash testing mode and the
#    default dashboard track.  Valid values are ``Continuous``, ``Nightly``,
#    and ``Experimental``.  See `Repository Test Classification`_ for a
#    detailed description.
#
# This command is used to put together one or more VC and/or TriBITS
# repositories to construct a composite `TriBITS Project`_.  The option
# `<Project>_EXTRAREPOS_FILE`_ is used to point to files that call this macro.
# Repositories with ``<repoi_packstat>=NOPACKAGES`` are **not** TriBITS
# Repositories and are technically not considered at all during the basic
# configuration of the a TriBITS project.  They are only listed in this file
# so that they can be used in the version control logic for tools that perform
# version control with the repositories (such as cloning, updating, looking
# for changed files, etc.).  For example, a non-TriBITS repo can be used to
# grab a set of directories and files that fill in the definition of a package
# in an upstream repository (see `How to insert a package into an upstream
# repo`_).  Also, non-TriBITS repos can be used to provide extra test data for
# a given package or a set of packages so that extra tests can be run.
#
# It is also allowed for a repository to have ``<repoi_url>=""`` and
# ``<repoi_packstat>=""`` which means that the given repository directory
# **is** a TriBITS Repository (and therefore provides TriBITS packages and
# TPLs) but that there is no independent VC repo used to manage the software.
#
# NOTE: These repositories must be listed in the order of package
# dependencies.  That is, all of the packages listed in repository ``i`` must
# have upstream TPL and SE package dependencies listed before this package in
# this repository or in upstream repositories ``i-1``, ``i-2``, etc.
#
# NOTE: This module just sets the local variable::
#
#  ${PROJECT_NAME}_EXTRAREPOS_DIR_REPOTYPE_REPOURL_PACKSTAT_CATEGORY
#
# in the current scope.  The advantages of using this macro instead of
# directly setting this variable are that the macro:
#
# * Asserts that the variable ``PROJECT_NAME`` is defined and set.
#
# * Avoids misspelling the name of the variable
#   ``${PROJECT_NAME}_EXTRAREPOS_DIR_REPOTYPE_REPOURL_PACKSTAT_CATEGORY``.  If
#   one misspells the name of a macro, it is an immediate error in CMake.  A
#   misspelled set variable is just ignored.
#
MACRO(TRIBITS_PROJECT_DEFINE_EXTRA_REPOSITORIES)
  ASSERT_DEFINED(PROJECT_NAME)
  IF ("${ARGN}" STREQUAL "")
    SET(${PROJECT_NAME}_EXTRAREPOS_DIR_REPOTYPE_REPOURL_PACKSTAT_CATEGORY)
  ELSE()
    SET(${PROJECT_NAME}_EXTRAREPOS_DIR_REPOTYPE_REPOURL_PACKSTAT_CATEGORY  "${ARGN}")
  ENDIF()
ENDMACRO()


#
# Field offsets
#

SET(ERP_REPO_NAME_OFFSET 0)
SET(ERP_REPO_DIR_OFFSET 1)
SET(ERP_REPO_REPOTYPE_OFFSET 2)
SET(ERP_REPO_REPOURL_OFFSET 3)
SET(ERP_REPO_PACKSTAT_OFFSET 4)
SET(ERP_REPO_CLASSIFICATION_OFFSET 5)

SET(ERP_NUM_FIELDS_PER_REPO 6)

#
# Dump the list of extra repos in verbose mode
#
FUNCTION(TRIBITS_DUMP_EXTRA_REPOSITORIES_LIST)
  IF (${PROJECT_NAME}_VERBOSE_CONFIGURE)
    PRINT_VAR(${PROJECT_NAME}_EXTRA_REPOSITORIES_DEFAULT)
    PRINT_VAR(${PROJECT_NAME}_EXTRA_REPOSITORIES_DIRS)
    PRINT_VAR(${PROJECT_NAME}_EXTRA_REPOSITORIES_REPOTYPES)
    PRINT_VAR(${PROJECT_NAME}_EXTRA_REPOSITORIES_REPOURLS)
    PRINT_VAR(${PROJECT_NAME}_EXTRA_REPOSITORIES_PACKSTATS)
    PRINT_VAR(${PROJECT_NAME}_EXTRA_REPOSITORIES_CATEGORIES)
  ENDIF()
ENDFUNCTION()


#
# Macro that processes the list varaible contents in
# ${PROJECT_NAME}_EXTRAREPOS_DIR_REPOTYPE_REPOURL_PACKSTAT_CATEGORY into sperate arrays:
#   ${PROJECT_NAME}_EXTRA_REPOSITORIES_DEFAULT
#   ${PROJECT_NAME}_EXTRA_REPOSITORIES_DIRS
#   ${PROJECT_NAME}_EXTRA_REPOSITORIES_REPOTYPES
#   ${PROJECT_NAME}_EXTRA_REPOSITORIES_REPOURLS
#   ${PROJECT_NAME}_EXTRA_REPOSITORIES_PACKSTATS
#   ${PROJECT_NAME}_EXTRA_REPOSITORIES_CATEGORIES
#
# The macro responds to ${PROJECT_NAME}_ENABLE_KNOWN_EXTERNAL_REPOS_TYPE
# to match the categories.
#
MACRO(TRIBITS_PROCESS_EXTRAREPOS_LISTS)

  # A) Get the total number of extrarepos defined

  IF (TRIBITS_PROCESS_EXTRAREPOS_LISTS_DEBUG)
    PRINT_VAR(${PROJECT_NAME}_EXTRAREPOS_DIR_REPOTYPE_REPOURL_PACKSTAT_CATEGORY)
  ENDIF()
  ASSERT_DEFINED(${PROJECT_NAME}_EXTRAREPOS_DIR_REPOTYPE_REPOURL_PACKSTAT_CATEGORY)
  LIST(LENGTH ${PROJECT_NAME}_EXTRAREPOS_DIR_REPOTYPE_REPOURL_PACKSTAT_CATEGORY
    ${PROJECT_NAME}_NUM_EXTRAREPOS_AND_FIELDS )
  MATH(EXPR ${PROJECT_NAME}_NUM_EXTRAREPOS
    "${${PROJECT_NAME}_NUM_EXTRAREPOS_AND_FIELDS}/${ERP_NUM_FIELDS_PER_REPO}")
  IF (TRIBITS_PROCESS_EXTRAREPOS_LISTS_DEBUG)
    PRINT_VAR(${PROJECT_NAME}_NUM_EXTRAREPOS)
  ENDIF()
  MATH(EXPR ${PROJECT_NAME}_LAST_EXTRAREPO_IDX "${${PROJECT_NAME}_NUM_EXTRAREPOS}-1")
  IF (TRIBITS_PROCESS_EXTRAREPOS_LISTS_DEBUG)
    PRINT_VAR(${PROJECT_NAME}_LAST_EXTRAREPO_IDX)
  ENDIF()

  # B) Process the list of extra repos

  SET(${PROJECT_NAME}_EXTRA_REPOSITORIES_DEFAULT)
  SET(${PROJECT_NAME}_EXTRA_REPOSITORIES_DIRS)
  SET(${PROJECT_NAME}_EXTRA_REPOSITORIES_REPOTYPES)
  SET(${PROJECT_NAME}_EXTRA_REPOSITORIES_REPOURLS)
  SET(${PROJECT_NAME}_EXTRA_REPOSITORIES_PACKSTATS)
  SET(${PROJECT_NAME}_EXTRA_REPOSITORIES_CATEGORIES)

  FOREACH(EXTRAREPO_IDX RANGE ${${PROJECT_NAME}_LAST_EXTRAREPO_IDX})

    # B.1) Extract the fields for the current extrarepo row

    # NAME
    MATH(EXPR EXTRAREPO_NAME_IDX
      "${EXTRAREPO_IDX}*${ERP_NUM_FIELDS_PER_REPO}+${ERP_REPO_NAME_OFFSET}")
    IF (TRIBITS_PROCESS_EXTRAREPOS_LISTS_DEBUG)
      PRINT_VAR(EXTRAREPO_NAME_IDX)
    ENDIF()
    LIST(GET ${PROJECT_NAME}_EXTRAREPOS_DIR_REPOTYPE_REPOURL_PACKSTAT_CATEGORY
      ${EXTRAREPO_NAME_IDX} EXTRAREPO_NAME )
    IF (TRIBITS_PROCESS_EXTRAREPOS_LISTS_DEBUG)
      PRINT_VAR(EXTRAREPO_NAME)
    ENDIF()

    # DIR
    MATH(EXPR EXTRAREPO_DIR_IDX
      "${EXTRAREPO_IDX}*${ERP_NUM_FIELDS_PER_REPO}+${ERP_REPO_DIR_OFFSET}")
    IF (TRIBITS_PROCESS_EXTRAREPOS_LISTS_DEBUG)
      PRINT_VAR(EXTRAREPO_DIR_IDX)
    ENDIF()
    LIST(GET ${PROJECT_NAME}_EXTRAREPOS_DIR_REPOTYPE_REPOURL_PACKSTAT_CATEGORY
      ${EXTRAREPO_DIR_IDX} EXTRAREPO_DIR )
    IF (TRIBITS_PROCESS_EXTRAREPOS_LISTS_DEBUG)
      PRINT_VAR(EXTRAREPO_DIR)
    ENDIF()
    IF (EXTRAREPO_DIR STREQUAL "")
      SET(EXTRAREPO_DIR ${EXTRAREPO_NAME})
    ENDIF()
    IF (TRIBITS_PROCESS_EXTRAREPOS_LISTS_DEBUG)
      PRINT_VAR(EXTRAREPO_DIR)
    ENDIF()

    # REPOTYPE
    MATH(EXPR EXTRAREPO_REPOTYPE_IDX
      "${EXTRAREPO_IDX}*${ERP_NUM_FIELDS_PER_REPO}+${ERP_REPO_REPOTYPE_OFFSET}")
    IF (TRIBITS_PROCESS_EXTRAREPOS_LISTS_DEBUG)
      PRINT_VAR(EXTRAREPO_REPOTYPE_IDX)
    ENDIF()
    LIST(GET ${PROJECT_NAME}_EXTRAREPOS_DIR_REPOTYPE_REPOURL_PACKSTAT_CATEGORY
      ${EXTRAREPO_REPOTYPE_IDX} EXTRAREPO_REPOTYPE )
    IF (EXTRAREPO_REPOTYPE STREQUAL GIT
      OR EXTRAREPO_REPOTYPE STREQUAL SVN
      )
      # Okay
    ELSEIF(EXTRAREPO_REPOTYPE STREQUAL HG)
      # not quite okay
      MESSAGE(WARNING "Warning: the repo ${EXTRAREPO_NAME} is a Mercurial repo: these are tolerated, but not fully supported.")
    ELSE()
      MESSAGE(FATAL_ERROR "Error, the repo type of '${EXTRAREPO_REPOTYPE}' for"
        " extra repo ${EXTRAREPO_NAME} is *not* valid.  Valid choices are 'GIT', 'HG' and 'SVN'!")
    ENDIF()
    IF (TRIBITS_PROCESS_EXTRAREPOS_LISTS_DEBUG)
      PRINT_VAR(EXTRAREPO_REPOTYPE)
    ENDIF()

    # REPOURL
    MATH(EXPR EXTRAREPO_REPOURL_IDX
      "${EXTRAREPO_IDX}*${ERP_NUM_FIELDS_PER_REPO}+${ERP_REPO_REPOURL_OFFSET}")
    IF (TRIBITS_PROCESS_EXTRAREPOS_LISTS_DEBUG)
      PRINT_VAR(EXTRAREPO_REPOURL_IDX)
    ENDIF()
    LIST(GET ${PROJECT_NAME}_EXTRAREPOS_DIR_REPOTYPE_REPOURL_PACKSTAT_CATEGORY
      ${EXTRAREPO_REPOURL_IDX} EXTRAREPO_REPOURL )
    IF (TRIBITS_PROCESS_EXTRAREPOS_LISTS_DEBUG)
      PRINT_VAR(EXTRAREPO_REPOURL)
    ENDIF()

    # PACKSTAT
    MATH(EXPR EXTRAREPO_PACKSTAT_IDX
      "${EXTRAREPO_IDX}*${ERP_NUM_FIELDS_PER_REPO}+${ERP_REPO_PACKSTAT_OFFSET}")
    LIST(GET ${PROJECT_NAME}_EXTRAREPOS_DIR_REPOTYPE_REPOURL_PACKSTAT_CATEGORY
      ${EXTRAREPO_PACKSTAT_IDX} EXTRAREPO_PACKSTAT )
    IF (TRIBITS_PROCESS_EXTRAREPOS_LISTS_DEBUG)
      PRINT_VAR(EXTRAREPO_PACKSTAT)
    ENDIF()
    IF (EXTRAREPO_PACKSTAT STREQUAL "")
      SET(EXTRAREPO_PACKSTAT HASPACKAGES)
    ELSEIF(EXTRAREPO_PACKSTAT STREQUAL NOPACKAGES)
      # Okay
    ELSE()
      MESSAGE(FATAL_ERROR "Error, the PACKSTAT of '${EXTRAREPO_PACKSTAT}' for"
        " extra repo ${EXTRAREPO_NAME} is *not* valid.  Valid choices are '' and 'NOPACKAGES'!")
    ENDIF()
    IF (TRIBITS_PROCESS_EXTRAREPOS_LISTS_DEBUG)
      PRINT_VAR(EXTRAREPO_PACKSTAT)
    ENDIF()

    # CLASSIFICATION
    MATH(EXPR EXTRAREPO_CLASSIFICATION_IDX
      "${EXTRAREPO_IDX}*${ERP_NUM_FIELDS_PER_REPO}+${ERP_REPO_CLASSIFICATION_OFFSET}")
    LIST(GET ${PROJECT_NAME}_EXTRAREPOS_DIR_REPOTYPE_REPOURL_PACKSTAT_CATEGORY
      ${EXTRAREPO_CLASSIFICATION_IDX} EXTRAREPO_CLASSIFICATION )
    IF (TRIBITS_PROCESS_EXTRAREPOS_LISTS_DEBUG)
      PRINT_VAR(EXTRAREPO_CLASSIFICATION)
    ENDIF()

    # B.2) Determine the match of the classification

    #ASSERT_DEFINED(${PROJECT_NAME}_ENABLE_KNOWN_EXTERNAL_REPOS_TYPE)
    IF (TRIBITS_PROCESS_EXTRAREPOS_LISTS_DEBUG)
      PRINT_VAR(${PROJECT_NAME}_ENABLE_KNOWN_EXTERNAL_REPOS_TYPE)
    ENDIF()

    SET(ADD_EXTRAREPO FALSE)

    IF (${PROJECT_NAME}_ENABLE_KNOWN_EXTERNAL_REPOS_TYPE STREQUAL "Continuous" AND
        EXTRAREPO_CLASSIFICATION STREQUAL "Continuous"
      )
      SET(ADD_EXTRAREPO TRUE)
    ELSEIF (${PROJECT_NAME}_ENABLE_KNOWN_EXTERNAL_REPOS_TYPE STREQUAL "Nightly" AND
        (EXTRAREPO_CLASSIFICATION STREQUAL "Continuous" OR EXTRAREPO_CLASSIFICATION STREQUAL "Nightly")
      )
      SET(ADD_EXTRAREPO TRUE)
    ENDIF()

    IF (TRIBITS_PROCESS_EXTRAREPOS_LISTS_DEBUG)
      PRINT_VAR(ADD_EXTRAREPO)
    ENDIF()


    # B.3) Add the extrarepo to the list if the classification matches

    IF (ADD_EXTRAREPO)
      LIST(APPEND ${PROJECT_NAME}_EXTRA_REPOSITORIES_DEFAULT ${EXTRAREPO_NAME})
      LIST(APPEND ${PROJECT_NAME}_EXTRA_REPOSITORIES_DIRS ${EXTRAREPO_DIR})
      LIST(APPEND ${PROJECT_NAME}_EXTRA_REPOSITORIES_REPOTYPES ${EXTRAREPO_REPOTYPE})
      LIST(APPEND ${PROJECT_NAME}_EXTRA_REPOSITORIES_REPOURLS ${EXTRAREPO_REPOURL})
      LIST(APPEND ${PROJECT_NAME}_EXTRA_REPOSITORIES_PACKSTATS ${EXTRAREPO_PACKSTAT})
      LIST(APPEND ${PROJECT_NAME}_EXTRA_REPOSITORIES_CATEGORIES ${EXTRAREPO_CLASSIFICATION})
    ELSE()
      LIST(APPEND CPACK_SOURCE_IGNORE_FILES
        "${${PROJECT_NAME}_SOURCE_DIR}/${EXTRAREPO_DIR}/")
    ENDIF()

  ENDFOREACH()

  # C) Get the actual number of active extra repos

  LIST(LENGTH ${PROJECT_NAME}_EXTRA_REPOSITORIES_DEFAULT ${PROJECT_NAME}_NUM_EXTRAREPOS )
  IF (TRIBITS_PROCESS_EXTRAREPOS_LISTS_DEBUG)
    PRINT_VAR(${PROJECT_NAME}_NUM_EXTRAREPOS)
  ENDIF()
  MATH(EXPR ${PROJECT_NAME}_LAST_EXTRAREPO_IDX "${${PROJECT_NAME}_NUM_EXTRAREPOS}-1")

  # D) Print the final set of extrarepos in verbose mode

  TRIBITS_DUMP_EXTRA_REPOSITORIES_LIST()

ENDMACRO()


#
# Assert the presents and the order of the list of extra repositories in
# ${PROJECT_NAME}_EXTRA_REPOSITORIES according to the list read in from the
# extra repos file as determined by the varaible
# ${PROJECT_NAME}_EXTRA_REPOSITORIES_DEFAULT.
#
FUNCTION(TRIBITS_EXTRA_REPOSITORIES_ASSERT_SUBSET_AND_ORDER_WRT_FILE)
  SET(EXTRA_REPOSITORIES_SORTED ${${PROJECT_NAME}_EXTRA_REPOSITORIES})
  TRIBITS_SORT_LIST_ACCORDING_TO_MASTER_LIST(
    "${${PROJECT_NAME}_EXTRA_REPOSITORIES_DEFAULT}" EXTRA_REPOSITORIES_SORTED)
  #PRINT_VAR(EXTRA_REPOSITORIES_SORTED)
  IF (NOT "${${PROJECT_NAME}_EXTRA_REPOSITORIES}" STREQUAL "${EXTRA_REPOSITORIES_SORTED}")
    MESSAGE(FATAL_ERROR
      "ERROR!  The list of extra repos passed in '${${PROJECT_NAME}_EXTRA_REPOSITORIES}'"
      " is not a subset and in the same order as read in from extra repos file '${${PROJECT_NAME}_EXTRA_REPOSITORIES_DEFAULT}'"
      )
  ENDIF()
ENDFUNCTION()


#
# Filter out or assert msising repos read from an extra repos.
#
# This macro keys off of the variables:
#
#  ${PROJECT_NAME}_EXTRA_REPOSITORIES
#  ${PROJECT_NAME}_IGNORE_MISSING_EXTRA_REPOSITORIES
#
# and the variables:
#
#   ${PROJECT_NAME}_EXTRA_REPOSITORIES_DEFAULT
#   ${PROJECT_NAME}_EXTRA_REPOSITORIES_DIRS
#   ${PROJECT_NAME}_EXTRA_REPOSITORIES_REPOTYPES
#   ${PROJECT_NAME}_EXTRA_REPOSITORIES_REPOURLS
#   ${PROJECT_NAME}_EXTRA_REPOSITORIES_PACKSTATS
#   ${PROJECT_NAME}_EXTRA_REPOSITORIES_CATEGORIES
#
# which contain the extra repos read from the extra repos file.
#
# If ${PROJECT_NAME}_EXTRA_REPOSITORIES is non-empty (it is assumed that the
# extra repos listed there is a subset of
# ${PROJECT_NAME}_EXTRA_REPOSITORIES_DEFAULT, which can be asserted so by
# calling TRIBITS_EXTRA_REPOSITORIES_ASSERT_SUBSET_AND_ORDER_WRT_FILE()), then
# the set of repos and the associated data will be filtered based on
# ${PROJECT_NAME}_EXTRA_REPOSITORIES.
#
# If ${PROJECT_NAME}_IGNORE_MISSING_EXTRA_REPOSITORIES==TRUE, then the set of
# repos will be filtered based on what repos are present.  If
# ${PROJECT_NAME}_IGNORE_MISSING_EXTRA_REPOSITORIES==FALSE, then all of the
# repos must exist or MESSSAGE(FATAL_ERROR ...) is called and will fail the
# configure.
#
# On output ${PROJECT_NAME}_EXTRA_REPOSITORIES will be set according to the
# logic described above and the other extra repo variables will be filtered in
# a consistent way.
#
MACRO(TRIBITS_FILTER_OR_ASSERT_EXTRA_REPOS)

  # ToDo: Also filter only those repos that are listed in
  # ${${PROJECT_NAME}_EXTRA_REPOSITORIES (which have already been asserted)

  # A) Loop through and copy info for existing repos to temp arrays

  SET(EXTRA_REPOSITORIES_TMP)
  SET(EXTRA_REPOSITORIES_DIRS_TMP)
  SET(EXTRA_REPOSITORIES_REPOTYPES_TMP)
  SET(EXTRA_REPOSITORIES_REPOURLS_TMP)
  SET(EXTRA_REPOSITORIES_PACKSTATS_TMP)
  SET(EXTRA_REPOSITORIES_CATEGORIES_TMP)

  # Set-up for filtering based on ${PROJECT_NAME}_EXTRA_REPOSITORIES != ""
  LIST(LENGTH ${PROJECT_NAME}_EXTRA_REPOSITORIES EXTRA_REPOSITORIES_IN_LEN)
  #PRINT_VAR(EXTRA_REPOSITORIES_IN_LEN)
  SET(EXTRAREPO_IN_IDX 0)
  IF (EXTRA_REPOSITORIES_IN_LEN GREATER 0)
    LIST(GET ${PROJECT_NAME}_EXTRA_REPOSITORIES ${EXTRAREPO_IN_IDX} EXTRAREPO_IN)
  ENDIF()

  SET(EXTRAREPO_IDX 0)
  FOREACH(EXTRAREPO_NAME ${${PROJECT_NAME}_EXTRA_REPOSITORIES_DEFAULT})

    #PRINT_VAR(EXTRAREPO_NAME)
    #PRINT_VAR(EXTRAREPO_IN)

    # A.1) Extract the data for current extra repo from file
    LIST(GET ${PROJECT_NAME}_EXTRA_REPOSITORIES_DIRS ${EXTRAREPO_IDX}
      EXTRAREPO_DIR )
    LIST(GET ${PROJECT_NAME}_EXTRA_REPOSITORIES_REPOTYPES ${EXTRAREPO_IDX}
      EXTRAREPO_REPOTYPE )
    LIST(GET ${PROJECT_NAME}_EXTRA_REPOSITORIES_REPOURLS ${EXTRAREPO_IDX}
      EXTRAREPO_REPOURL )
    LIST(GET ${PROJECT_NAME}_EXTRA_REPOSITORIES_PACKSTATS ${EXTRAREPO_IDX}
      EXTRAREPO_PACKSTAT )
    LIST(GET ${PROJECT_NAME}_EXTRA_REPOSITORIES_CATEGORIES ${EXTRAREPO_IDX}
      EXTRAREPO_CATEGORY )

    # A.2) Determine if the add the extra repo EXTRAREPO_NAME

    # A.2.a) Assume we will add repo to begin with
    SET(ADD_EXTRAREPO TRUE)

    # A.2.b) Filter based on ${PROJECT_NAME}_EXTRA_REPOSITORIES
    IF (EXTRA_REPOSITORIES_IN_LEN  GREATER  0)

      IF (EXTRAREPO_IN_IDX EQUAL EXTRA_REPOSITORIES_IN_LEN)
        # All of the extra repos in ${PROJECT_NAME}_EXTRA_REPOSITORIES have
        # already been processed
        SET(ADD_EXTRAREPO FALSE)
      ELSEIF (EXTRAREPO_IN STREQUAL EXTRAREPO_NAME)
        # We have a match!
        MATH(EXPR EXTRAREPO_IN_IDX "${EXTRAREPO_IN_IDX}+1")
        IF (EXTRAREPO_IN_IDX LESS EXTRA_REPOSITORIES_IN_LEN)
          LIST(GET ${PROJECT_NAME}_EXTRA_REPOSITORIES ${EXTRAREPO_IN_IDX} EXTRAREPO_IN)
        ELSE()
          SET(EXTRAREPO_IN  "")
        ENDIF()
      ELSE()
        # We are not at the end of the list in ${PROJECT_NAME}_EXTRA_REPOSITORIES yet
        # and have not reached the next entry in the list so don't add.
        SET(ADD_EXTRAREPO FALSE)
      ENDIF()
    ENDIF()

    #PRINT_VAR(ADD_EXTRAREPO)

    # A.2) Determine if the repo exists
    IF (ADD_EXTRAREPO AND ${PROJECT_NAME}_CHECK_EXTRAREPOS_EXIST)

      ASSERT_DEFINED(PROJECT_SOURCE_DIR)
      SET(EXTRAREPO_SOURCE_DIR "${PROJECT_SOURCE_DIR}/${EXTRAREPO_DIR}")
      IF (EXISTS "${EXTRAREPO_SOURCE_DIR}")
        SET(EXTRAREPO_EXISTS TRUE)
      ELSE()
        SET(EXTRAREPO_EXISTS FALSE)
      ENDIF()
      #PRINT_VAR(EXTRAREPO_EXISTS)

      IF (NOT EXTRAREPO_EXISTS)
        SET(ADD_EXTRAREPO FALSE)
        IF (${PROJECT_NAME}_IGNORE_MISSING_EXTRA_REPOSITORIES)
          MESSAGE("-- "
            "WARNING: Ignoring missing extra repo '${EXTRAREPO_NAME}'"
            " as requested since ${EXTRAREPO_SOURCE_DIR} does not exist" )
        ELSE()
          MESSAGE( FATAL_ERROR
            "ERROR!  Skipping missing extra repo '${EXTRAREPO_NAME}'"
            " since ${EXTRAREPO_SOURCE_DIR} does not exist!\n")
        ENDIF()
      ENDIF()

    ENDIF()

    #PRINT_VAR(ADD_EXTRAREPO)

    # A.3) Conditionally copy the info for the extra repo
    IF (ADD_EXTRAREPO)
      MESSAGE("-- " "Adding extra ${EXTRAREPO_CATEGORY} repository ${EXTRAREPO_NAME} ...")
      LIST(APPEND EXTRA_REPOSITORIES_TMP ${EXTRAREPO_NAME})
      LIST(APPEND EXTRA_REPOSITORIES_DIRS_TMP ${EXTRAREPO_DIR})
      LIST(APPEND EXTRA_REPOSITORIES_REPOTYPES_TMP ${EXTRAREPO_REPOTYPE})
      LIST(APPEND EXTRA_REPOSITORIES_REPOURLS_TMP ${EXTRAREPO_REPOURL})
      LIST(APPEND EXTRA_REPOSITORIES_PACKSTATS_TMP ${EXTRAREPO_PACKSTAT})
      LIST(APPEND EXTRA_REPOSITORIES_CATEGORIES_TMP ${EXTRAREPO_CLASSIFICATION})
   ENDIF()

    MATH(EXPR EXTRAREPO_IDX "${EXTRAREPO_IDX}+1")

  ENDFOREACH()

  # B) Copy over extra repos arrays with filtered arrays
  SET(${PROJECT_NAME}_EXTRA_REPOSITORIES ${EXTRA_REPOSITORIES_TMP})
  SET(${PROJECT_NAME}_EXTRA_REPOSITORIES_DIRS ${EXTRA_REPOSITORIES_DIRS_TMP})
  SET(${PROJECT_NAME}_EXTRA_REPOSITORIES_REPOTYPES ${EXTRA_REPOSITORIES_REPOTYPES_TMP})
  SET(${PROJECT_NAME}_EXTRA_REPOSITORIES_REPOURLS ${EXTRA_REPOSITORIES_REPOURLS_TMP})
  SET(${PROJECT_NAME}_EXTRA_REPOSITORIES_PACKSTATS ${EXTRA_REPOSITORIES_PACKSTATS_TMP})
  SET(${PROJECT_NAME}_EXTRA_REPOSITORIES_CATEGORIES ${EXTRA_REPOSITORIES_CATEGORIES_TMP})

  TRIBITS_DUMP_EXTRA_REPOSITORIES_LIST()

ENDMACRO()


#
# Macro that reads extra repos file, processes the list of extra repos, etc.
#
# On input, the following variables are read:
#
#   ${PROJECT_NAME}_EXTRAREPOS_FILE
#   ${PROJECT_NAME}_IGNORE_MISSING_EXTRA_REPOSITORIES
#   ${PROJECT_NAME}_EXTRA_REPOSITORIES
#
# On output, the following varaibles are set:
#
#   ???
#
MACRO(TRIBITS_GET_AND_PROCESS_EXTRA_REPOSITORIES_LISTS)

  #
  # A) Read in the extra repos list variable and process the list
  #

  IF (${PROJECT_NAME}_EXTRAREPOS_FILE AND ${PROJECT_NAME}_ENABLE_KNOWN_EXTERNAL_REPOS_TYPE)

    MESSAGE("")
    MESSAGE("Reading the list of extra repositories from ${${PROJECT_NAME}_EXTRAREPOS_FILE}")
    MESSAGE("")

    INCLUDE(${${PROJECT_NAME}_EXTRAREPOS_FILE})

    TRIBITS_PROCESS_EXTRAREPOS_LISTS()
    # Above sets ${PROJECT_NAME}_EXTRA_REPOSITORIES_DEFAULT

    #
    # B) Sort and assert the list of extra repos according to the list read into the file
    #

    IF (${PROJECT_NAME}_EXTRA_REPOSITORIES AND ${PROJECT_NAME}_EXTRA_REPOSITORIES_DEFAULT)
      TRIBITS_EXTRA_REPOSITORIES_ASSERT_SUBSET_AND_ORDER_WRT_FILE()
    ENDIF()

    #
    # C) Filter out the missing extra repos or assert errors
    #

    IF (NOT UNITTEST_SKIP_FILTER_OR_ASSERT_EXTRA_REPOS)
      MESSAGE("")
      MESSAGE("Filtering and asserting existance (or ignore missing) extra repos ...")
      MESSAGE("")
      TRIBITS_FILTER_OR_ASSERT_EXTRA_REPOS()
    ELSE()
      SET(${PROJECT_NAME}_EXTRA_REPOSITORIES ${${PROJECT_NAME}_EXTRA_REPOSITORIES_DEFAULT})
    ENDIF()

  ENDIF()

ENDMACRO()


#
# Extract the final name of the extra repo
#
FUNCTION(TRIBITS_GET_EXTRAREPO_BASE_NAME  EXTRAREPO_NAME EXTRAREPO_NAME_OUT)
  GET_FILENAME_COMPONENT(EXTRAREPO_NAME "${EXTRAREPO_NAME}" NAME)
  SET(${EXTRAREPO_NAME_OUT} "${EXTRAREPO_NAME}" PARENT_SCOPE)
ENDFUNCTION()
