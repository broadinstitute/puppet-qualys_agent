#!/bin/bash
#
# This is just a simple wrapper script around the dpl command so that user and password do not
# have to be specified on the command-line.
#

if [ -z "$FORGE_USER" ]; then
    echo "FORGE_USER was not set."
    exit 1
fi

if [ -z "$FORGE_PASSWORD" ]; then
    echo "FORGE_PASSWORD was not set."
    exit 2
fi

# Make sure the command is not printed to stdout
set +x
# Call the dpl command for uploading to the forge
bundle exec dpl --provider=puppetforge --user="$FORGE_USER" --password="$FORGE_PASSWORD"
