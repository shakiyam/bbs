#!/bin/bash
set -eu -o pipefail

wercker build --working-dir ~/.wercker/ --pipeline rspec
