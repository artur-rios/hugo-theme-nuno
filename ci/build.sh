#!/bin/sh
# The `build` check: .github/workflows/build.yml (left as upstream has it), which builds exampleSite with the theme
# and fails on any Hugo WARN (Hugo exits 0 on a warning, so a missing i18n key or an unresolvable asset path would
# otherwise pass). The workflow builds with the oldest Hugo theme.toml claims (min_version 0.158.0) and the newest;
# here it is the pinned Hugo of yggdrasil.yml, the newest the hugomods images have.
#
# The site finds the theme as `nuno` under --themesDir, so the checkout (whatever its directory is called) is linked
# under that name in a temporary directory, which also takes the built site: nothing is written to the checkout but
# Hugo's own cache, exampleSite/resources/ (ignored by git).
#
# yggdrasil.yml runs it in the pinned Hugo image from the repository's root. By hand:
#   docker run --rm -v "$PWD:/src" -w /src <image from yggdrasil.yml> sh ci/build.sh
set -eu

# The repository's root, wherever this is run from.
cd "$(dirname "$0")/.."
root=$(pwd)

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir "$work/themes"
ln -s "$root" "$work/themes/nuno"

hugo version
cd exampleSite
status=0
hugo --themesDir "$work/themes" --destination "$work/public" \
  --printI18nWarnings --printPathWarnings --logLevel info >"$work/hugo.log" 2>&1 || status=$?
cat "$work/hugo.log"
[ "$status" -eq 0 ] || exit "$status"
# The site must have been written, and without a single warning.
test -s "$work/public/index.html"
if grep -q '^WARN' "$work/hugo.log"; then
  echo "ci/build.sh: Hugo emitted warnings (above)" >&2
  exit 1
fi
