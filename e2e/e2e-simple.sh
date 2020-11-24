#!/bin/bash
# Copyright (c) 2015-present, Facebook, Inc.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

# ******************************************************************************
# This is an end-to-end test intended to run on CI.
# You can also run it locally but it's slow.
# ******************************************************************************

# Start in tasks/ even if run from root directory
cd "$(dirname "$0")"

# App temporary location
# http://unix.stackexchange.com/a/84980
temp_app_path=`mktemp -d 2>/dev/null || mktemp -d -t 'temp_app_path'`


function cleanup {
  echo 'Cleaning up.'
  cd "$root_path"
  # Uncomment when snapshot testing is enabled by default:
  # rm ./packages/npack-scripts/template/src/__snapshots__/App.test.js.snap
  rm -rf "$temp_app_path"
}

# Error messages are redirected to stderr
function handle_error {
  echo "$(basename $0): ERROR! An error was encountered executing line $1." 1>&2;
  cleanup
  echo 'Exiting with error.' 1>&2;
  exit 1
}

function handle_exit {
  cleanup
  echo 'Exiting without error.' 1>&2;
  exit
}

# Check for the existence of one or more files.
function exists {
  for f in $*; do
    test -e "$f"
  done
}

# Exit the script with a helpful error message when any error is encountered
trap 'set +x; handle_error $LINENO $BASH_COMMAND' ERR

# Cleanup before exit on any termination signal
trap 'set +x; handle_exit' SIGQUIT SIGTERM SIGINT SIGKILL SIGHUP

# Echo every command being executed
set -x

# Go to root
cd ..
root_path=$PWD

# Make sure we don't introduce accidental references to PATENTS.
#EXPECTED='packages/react-error-overlay/fixtures/bundle.mjs
#packages/react-error-overlay/fixtures/bundle.mjs.map
#packages/react-error-overlay/fixtures/bundle_u.mjs
#packages/react-error-overlay/fixtures/bundle_u.mjs.map
#tasks/e2e-simple.sh'
#ACTUAL=$(git grep -l PATENTS)
#if [ "$EXPECTED" != "$ACTUAL" ]; then
#  echo "PATENTS crept into some new files?"
#  diff -u <(echo "$EXPECTED") <(echo "$ACTUAL") || true
#  exit 1
#fi

if hash npm 2>/dev/null
then
  npm i -g npm@latest
fi

# Bootstrap monorepo
yarn


# ******************************************************************************
# First, test the create-npack-app development environment.
# This does not affect our users but makes sure we can develop it.
# ******************************************************************************

# Test local build command
yarn build
# Check for expected output
#exists build/*.html
exists build/*.js
#exists build/static/css/*.css
#exists build/static/media/*.svg
#exists build/favicon.ico

# Run tests with CI flag
CI=true yarn test
# Uncomment when snapshot testing is enabled by default:
# exists template/src/__snapshots__/App.test.js.snap

# Test local start command
yarn start --smoke-test

# ******************************************************************************
# Install npack-scripts prerelease via create-npack-app prerelease.
# ******************************************************************************

# Install the app in a temporary location
cd $temp_app_path
npx create-npack-app test-app

# TODO: verify we installed prerelease

# ******************************************************************************
# Now that we used create-npack-app to create an app depending on npack-scripts,
# let's make sure all npm scripts are in the working state.
# ******************************************************************************


function verify_module_scope {
  # Create stub json file
  echo "{}" >> sample.json

  # Save App.js, we're going to modify it
  cp src/App.js src/App.js.bak

  # Add an out of scope import
  echo "import sampleJson from '../sample'" | cat - src/App.js > src/App.js.temp && mv src/App.js.temp src/App.js

  # Make sure the build fails
  yarn build; test $? -eq 1 || exit 1
  # TODO: check for error message

  rm sample.json

  # Restore App.js
  rm src/App.js
  mv src/App.js.bak src/App.js
}

# Enter the app directory
cd test-app

# Test the build
yarn build
# Check for expected output
#exists build/*.html
exists build/*.js
#exists build/static/css/*.css
#exists build/static/media/*.svg
#exists build/favicon.ico

# Run tests with CI flag
CI=true yarn test
# Uncomment when snapshot testing is enabled by default:
# exists src/__snapshots__/App.test.js.snap

# Test the server
yarn start --smoke-test

# Test reliance on webpack internals
verify_module_scope

# ******************************************************************************
# Finally, let's check that everything still works after ejecting.
# ******************************************************************************

# Eject...
echo yes | npm run eject

# Test ejected files were staged
test -n "$(git diff --staged --name-only)"

# Test the build
yarn build
# Check for expected output
#exists build/*.html
exists build/*.js
#exists build/static/css/*.css
#exists build/static/media/*.svg
#exists build/favicon.ico

# Run tests, overriding the watch option to disable it.
# `CI=true yarn test` won't work here because `yarn test` becomes just `jest`.
# We should either teach Jest to respect CI env variable, or make
# `scripts/test.js` survive ejection (right now it doesn't).
yarn test --watch=no
# Uncomment when snapshot testing is enabled by default:
# exists src/__snapshots__/App.test.js.snap

# Test the server
yarn start --smoke-test

# Test reliance on webpack internals
verify_module_scope

# Cleanup
cleanup
