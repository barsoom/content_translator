#!/bin/bash

set -e

# Add heroku cli if missing
if [ ! -x heroku ]; then
  echo "---> Install Heroku CLI"
  wget https://cli-assets.heroku.com/branches/stable/heroku-linux-amd64.tar.gz >/dev/null
  sudo mkdir -p /usr/local/lib /usr/local/bin >/dev/null
  sudo tar -xvzf heroku-linux-amd64.tar.gz -C /usr/local/lib >/dev/null
  sudo ln -s /usr/local/lib/heroku/bin/heroku /usr/local/bin/heroku >/dev/null
fi

# Add config for heroku commands and git based deploy over https
echo -e "machine api.heroku.com\n  login $HEROKU_API_USER\n  password $HEROKU_API_TOKEN\nmachine code.heroku.com\n  login $HEROKU_API_USER\n  password $HEROKU_API_TOKEN\nmachine git.heroku.com\n  login $HEROKU_API_USER\n  password $HEROKU_API_TOKEN" > ~/.netrc
chmod 0600 ~/.netrc

cd ~/project

# Deploy
revision=$(git rev-parse HEAD)
app_name=$1

function _main {
  _deploy_to_heroku
  _smoke_test
}

function _deploy_to_heroku {
  heroku git:remote --app $app_name

  # Workaround for https://github.com/travis-ci/dpl/issues/127#issuecomment-42397378
  set +e
  git fetch --unshallow 2> /dev/null
  set -e

  git push heroku master
}

function _smoke_test {
  ruby script/ci/support/wait_for_new_revision_to_serve_requests.rb $app_name $revision

  echo
  echo "Running smoke test."

  APP_URL=https://$app_name.herokuapp.com script/ci/smoke_test.sh
}

_main
