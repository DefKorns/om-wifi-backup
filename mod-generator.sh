#!/bin/bash
#
#  Copyright (c) 2020 DefKorns (https://defkorns.github.io/LICENSE)
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# shellcheck disable=SC2001
PKG_PRETTY_NAME="Wifi Backup"
PKG_NAME="om-wifi-backup"
PKG_CREATOR="DefKorns"
PKG_CATEGORY="Options Menu"
MAINTAINER="DefKorns <defkorns@gmail.com>"
PLATFORM="SNESCE"
ARCHITECTURE="armhf"

PKG_TARGET="${PKG_NAME}_${PLATFORM}"
PREINST="${PKG_TARGET}/install"
POSTRM="${PKG_TARGET}/uninstall"

DEV_DIR="$(pwd)"
HMOD="${DEV_DIR}/${PKG_TARGET}.hmod"

VERSION="$([ -f VERSION ] && head VERSION || echo "0.0.1")"
VERSION_FILE="${DEV_DIR}/VERSION"

LAST_TAG_COMMIT=$(git rev-list --tags --max-count=1)
LAST_TAG=$(git describe --tags "${LAST_TAG_COMMIT}")

MAJOR=$(echo "${VERSION}" | sed "s/^\([0-9]*\).*/\1/")
MINOR=$(echo "${VERSION}" | sed "s/[0-9]*\.\([0-9]*\).*/\1/")
PATCH=$(echo "${VERSION}" | sed "s/[0-9]*\.[0-9]*\.\([0-9]*\).*/\1/")

NEXT_MAJOR_VERSION="$((MAJOR + 1)).0.0"
NEXT_MINOR_VERSION="${MAJOR}.$((MINOR + 1))"
NEXT_PATCH_VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))"

modCreation() {
  mkdir -p "${PKG_TARGET}"
  cp -rf mod/* ${PKG_TARGET}/
  {
    printf "%s\n" \
      "---" \
      "Name: ${PKG_PRETTY_NAME}" \
      "Creator: ${PKG_CREATOR}" \
      "Category: ${PKG_CATEGORY}" \
      "Version: ${VERSION}" \
      "Built: $(date)" \
      "---"
  } >"${PKG_TARGET}/readme.md"

  sed 1d mod/readme.md >>"${PKG_TARGET}/readme.md"

  [ -f "preinst" ] && cp -rf preinst ${PREINST} && chmod 755 ${PREINST}
  [ -f "postrm" ] && cp -rf postrm ${POSTRM} && chmod 755 ${POSTRM}

  cd "${PKG_TARGET}" || exit
  tar -czf "${HMOD}" -- *
  rm -r "${DEV_DIR:?}/${PKG_TARGET}"
  touch "${HMOD}"

}

clean() {
  rm -rf "${DEV_DIR:?}/${PKG_TARGET:?}/" "${DEV_DIR:?}/${PKG_TARGET}.mod"
}

case "$1" in
clean)
  clean
  ;;
minor)
  clean
  modCreation
  echo "${NEXT_MINOR_VERSION}" >"${VERSION_FILE}"
  ;;
major)
  clean
  modCreation
  echo "${NEXT_MAJOR_VERSION}" >"${VERSION_FILE}"
  ;;
info)
  printf "%s\n" \
    "Package: ${PKG_NAME}" \
    "Author: ${PKG_CREATOR}" \
    "Version: ${VERSION}" \
    "Built: $(date)" \
    "Architecture: ${ARCHITECTURE}" \
    "Platform: ${PLATFORM} ${ARCHITECTURE}" \
    "Maintainer: ${MAINTAINER}" \
    "Description: ${PKG_PRETTY_NAME}"
    cat readme.md
  ;;
*)
  clean
  modCreation
  echo "${NEXT_PATCH_VERSION}" >"${VERSION_FILE}"
  ;;
esac
#EOF
