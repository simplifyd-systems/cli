#!/bin/bash
{
    set -e
    SUDO=''
    if [ "$(id -u)" != "0" ]; then
      SUDO='sudo'
      echo ""
      echo "This script requires superuser access."
      echo "You will be prompted for your password by sudo."
      echo ""
      # clear any previous sudo permission
      sudo -k
    fi


    # run inside sudo
    $SUDO bash <<SCRIPT
  set -e

  echoerr() { echo "\$@" 1>&2; }

  if [[ ! ":\$PATH:" == *":/usr/local/bin:"* ]]; then
    echoerr "Your path is missing /usr/local/bin, you need to add this to use this installer."
    exit 1
  fi

  if [ "\$(uname)" == "Darwin" ]; then
    OS=macOS
    ARCH=all
  elif [ "\$(expr substr \$(uname -s) 1 5)" == "Linux" ]; then
    OS=Linux
    RAWARCH="\$(uname -m)"
    if [ "\$RAWARCH" == "x86_64" ]; then
      ARCH=x86_64
    elif [[ "\$RAWARCH" == arm64 ]] || [[ "\$RAWARCH" == aarch64 ]]; then
      ARCH=arm64
    else
      echoerr "unsupported arch: \$RAWARCH"
      exit 1
    fi
  else
    echoerr "This installer is only supported on Linux and MacOS"
    exit 1
  fi

  echo ""
  echo "Detected environment is: \$OS \$ARCH"
  echo ""

  VERSION=0.1.4
  FILENAME="edge_\${VERSION}_\${OS}_\${ARCH}.tar.gz"
  URL="https://github.com/simplifyd-systems/cli/releases/download/v\${VERSION}/\${FILENAME}"
  TAR_ARGS="xzf"

  mkdir -p /usr/local/lib/simplifyd
  cd /usr/local/lib/simplifyd

  echo "Installing Simplifyd CLI from \$URL"
  echo ""
  if [ \$(command -v curl) ]; then
    curl -OL "\$URL"
  else
    wget "\$URL"
  fi

  tar "\$TAR_ARGS" "\$FILENAME"

  # delete old symlink if exists
  rm -f /usr/local/bin/edge
  ln -s /usr/local/lib/simplifyd/edge /usr/local/bin/edge

SCRIPT
  # test the CLI
  LOCATION=$(command -v edge)
  echo ""
  echo "Simplifyd CLI installed successfully to $LOCATION"
}
