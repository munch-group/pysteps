#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

if [[ `git status --porcelain` ]]; then
  echo -e "${RED}Changes to pyproject.toml must be pushed first.${NC}"
  exit
else
  v=$(python -c "
import sys
try:
    import tomllib
except ImportError:
    import tomli as tomllib
with open('pyproject.toml', 'rb') as f:
    data = tomllib.load(f)
print(data['project']['version'])
") || exit
  p=$(python -c "'--prerelease' if 'rc' in \"$v\" else '--latest' ") || exit

  # git tag -a "v${v}" -m "${1:-Release}" && git push origin --tags && echo -e "${GREEN}Released version v${v} ${NC}" && exit
  set -v
  s="
try:
    import tomllib
except ImportError:
    import tomli as tomllib  
import tomllib
print(tomllib.load(open('pyproject.toml', 'rb'))['project']['version'])
"
  gh release create $p "v${v}" --title "v"$(python -c $s) --notes "" && exit
fi
echo -e "${RED}Failed${NC}"
