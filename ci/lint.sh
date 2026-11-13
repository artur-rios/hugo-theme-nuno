#!/bin/sh
# The `lint` check: every file against the theme's own .editorconfig (charset, LF line endings, final newline,
# trailing whitespace, spaces not tabs), with editorconfig-checker. .editorconfig-checker.json turns off only its
# indent-size rule, which counts the alignment spaces of wrapped template lines as wrong indentation, and leaves out
# the vendored font files (their licence text is upstream's).
#
# yggdrasil.yml runs it in the pinned editorconfig-checker image (Alpine: POSIX sh) from the repository's root. By hand:
#   docker run --rm -v "$PWD:/src" -w /src <image from yggdrasil.yml> sh ci/lint.sh
set -eu

# The repository's root, wherever this is run from.
cd "$(dirname "$0")/.."

editorconfig-checker --version
editorconfig-checker -no-color
