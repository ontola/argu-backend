#!/bin/bash

if [ $EUID != 0 ]; then
    sudo USR=$USER USR_HOME=$HOME "$0" "$@"
    exit $?
fi

generate_password() {
  head -c 128 /dev/urandom | LC_CTYPE=C tr -dc 'a-zA-Z0-9'
}

init_docker_config() {
  if [ ! -f config/$1.yml ]; then
    sudo -u $USR cp config/$1.docker.yml config/$1.yml
  fi
}

init_secrets() {
  if [ ! -f $1 ]; then
    sudo -u $USR /bin/bash -c "sed \"s/{secret}/$2/g\" $1.template > $1"
  fi
}

install_packages() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Propert depencency installation not yet implemented for osx (so ticket+PR)"
    install_rbenv
    install_nvm
  elif [[ "$OSTYPE" == "win32" ]]; then
    echo "Dependency installation not yet implemented for windows (so ticket+PR)"
  else
    sudo apt-get -qq install -y \
      build-essential \
      git \
      libgsf-1-dev \
      libpq-dev \
      libxml2 \
      postgresql-contrib \
      zlib1g-dev
    # Vips and dependencies
    sudo apt-get -qq install -f -y \
      libvips-dev \
      libvips-tools
    # ImageMagick and dependencies
    sudo apt-get -qq install -y \
      imagemagick \
      libgsf-1-dev \
      libmagickwand-dev
    # Qtwebkit
    sudo apt-get -qq install -y \
      qt5-default \
      libqt5webkit5-dev \
      gstreamer1.0-plugins-base \
      gstreamer1.0-tools \
      gstreamer1.0-x

    install_rbenv
    install_nvm
  fi
}

install_nvm() {
  if command -v nvm && command -v node; then
    echo "nvm and node already installed, skipping"
    return
  fi
  if [ ! -d $USR_HOME/.nvm  ]; then
    sudo -u $USR git clone -q https://github.com/creationix/nvm.git $USR_HOME/.nvm
    nvm_line='export NVM_DIR="$HOME/.nvm"\n[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"'
    printf $nvm_line >> $USR_HOME/.bash_profile
    printf $nvm_line >> $USR_HOME/.bashrc
    printf $nvm_line >> $USR_HOME/.zshrc
  fi
  if ! command -v node; then
    sudo -u $USR /bin/bash -c '. $HOME/.nvm/nvm.sh && nvm install --lts node --silent &&  nvm use --lts node'
  fi
}

install_rbenv() {
  if command -v rbenv || command -v rvm; then
    echo "rbenv or rvm already installed, skipping"
    return
  fi
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sudo -u $USR brew update
    sudo -u $USR brew install rbenv ruby-build
    rbenv init
  else
      if [ ! -d $USR_HOME/.rbenv  ]; then
        sudo -u $USR git clone -q https://github.com/rbenv/rbenv.git ~/.rbenv
        echo 'export PATH="$USR_HOME/.rbenv/bin:$PATH"' >> $USR_HOME/.bash_profile
        echo 'export PATH="$USR_HOME/.rbenv/bin:$PATH"' >> $USR_HOME/.bashrc
        echo 'export PATH="$USR_HOME/.rbenv/bin:$PATH"' >> $USR_HOME/.zshrc
        sudo -u $USR git clone -q https://github.com/rbenv/ruby-build.git $USR_HOME/.rbenv/plugins/ruby-build
      fi
  fi
}

init_submodules() {
  sudo -u $USR git submodule update --init
}

setup_database() {
  docker-compose --file ./compose/docker-compose.yml run app bundle exec rake db:setup
}

setup_dependencies() {
  install_packages
  docker volume create --name=data
}

setup_javascript() {
  if ! command -v yarn
  then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sudo -u $USR brew install yarn
    elif [[ "$OSTYPE" == "win32" ]]; then
      if ! command -v yarn
      then
        echo "Yarn command not present, not building JS files (so ticket+PR)"
        return
      fi
    else
      echo "Setting up yarn"
      curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -y -
      echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
      sudo apt-get -qq update
      sudo apt-get -qq install -y yarn
    fi
  fi

  sudo -u $USR /bin/bash -ic '. $HOME/.nvm/nvm.sh && yarn'
  sudo -u $USR /bin/bash -ic '. $HOME/.nvm/nvm.sh && yarn run build'
}

password=$(generate_password)
init_secrets ./.env $password
init_secrets ./compose/postgres.env $password
init_docker_config database
init_docker_config secrets
init_submodules
setup_dependencies
setup_database
setup_javascript
