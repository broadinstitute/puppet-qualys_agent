#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Check version in metadata against GitHub tag."""

import json
import os
import sys


def check_version():
    """Check the tag and metadata to make sure they are the same version number."""
    pwd = os.path.dirname(os.path.realpath(os.path.dirname(__file__)))

    mdfile = open(os.path.join(pwd, "metadata.json"), "r")
    metastr = mdfile.read()
    metadata = json.loads(metastr)
    mdfile.close()

    tagver = os.getenv("CIRCLE_TAG")

    if tagver == metadata["version"]:
        print("Versions match: %s" % tagver)
        return 0
    else:
        print("Version mismatch: tag(%s) != metadata(%s)" % (tagver, metadata["version"]))
        return 1


if __name__ == "__main__":
    RET = check_version()

    sys.exit(RET)
