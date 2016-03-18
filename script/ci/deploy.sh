#!/bin/bash

set -e

# Add config for heroku commands like "heroku config:set" and git based deploy over https
echo -e "machine api.heroku.com\n  login $HEROKU_API_USER\n  password $HEROKU_API_TOKEN\nmachine code.heroku.com\n  login $HEROKU_API_USER\n  password $HEROKU_API_TOKEN\nmachine git.heroku.com\n  login $HEROKU_API_USER\n  password $HEROKU_API_TOKEN" > ~/.netrc
chmod 0600 ~/.netrc

cd ~/$CIRCLE_PROJECT_REPONAME

# Deploy
revision=$(git rev-parse HEAD)
app_name=$1

function _main {
  _deploy_to_heroku
  _smoke_test
}

function _deploy_to_heroku {
  heroku git:remote --app $app_name
  git push heroku master
  heroku config:set GIT_COMMIT=$revision -a $app_name
}

function _smoke_test {
  ruby script/ci/support/wait_for_new_revision_to_serve_requests.rb $app_name $revision

  echo
  echo "Running smoke test."

  APP_URL=https://$app_name.herokuapp.com script/ci/smoke_test.sh
}

_main
