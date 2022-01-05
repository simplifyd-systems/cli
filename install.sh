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
    OS=Darwin
  elif [ "\$(expr substr \$(uname -s) 1 5)" == "Linux" ]; then
    OS=Linux
  else
    echoerr "This installer is only supported on Linux and MacOS"
    exit 1
  fi

  echo ""
  echo "Detected environment is: \$OS"
  echo ""

  ARCH="\$(uname -m)"
  if [ "\$ARCH" == "x86_64" ]; then
    ARCH=x86_64
  elif [[ "\$ARCH" == arm64 ]]; then
    ARCH=arm64
  elif [[ "\$ARCH" == arm* ]]; then
    ARCH=arm
  else
    echoerr "unsupported arch: \$ARCH"
    exit 1
  fi

  mkdir -p /usr/local/lib/
  cd /usr/local/lib/
  rm -rf simplifyd
  mkdir -p /usr/local/lib/simplifyd
  cd /usr/local/lib/simplifyd

  URL=https://github.com/simplifyd-systems/cli/releases/download/0.0.1/\$OS-\$ARCH.tar.gz
  TAR_ARGS="xzf"

  echo "Installing Simplifyd CLI from \$URL"
  echo ""
  if [ \$(command -v curl) ]; then
    curl -OL "\$URL"
    tar "\$TAR_ARGS" \$OS-\$ARCH.tar.gz
  else
    wget -O- "\$URL"
    tar "\$TAR_ARGS" \$OS-\$ARCH.tar.gz
  fi
  
  # delete old simplifyd bin if exists
  rm -f \$(command -v edge) || true
  rm -f /usr/local/bin/edge
  ln -s /usr/local/lib/simplifyd/edge-cli /usr/local/bin/edge

SCRIPT
  # test the CLI
  LOCATION=$(command -v edge)
  echo ""
  echo "Simplifyd CLI installed successfully to $LOCATION"
  # simplifyd version
}
