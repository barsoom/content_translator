# Setting up automatic deploy:

# 1) Add your fork of this project to circleci
# 2) Set up .netrc under "Dependency commands" like https://gist.github.com/joakimk/5efe8d04e526d521e8c6
# 3) Set HEROKU_USER, HEROKU_API_KEY and HEROKU_APP_NAME1 in "Environment variables".
# 4) Trigger a build

[ $HEROKU_APP_NAME1 ] && git push git@heroku.com:$HEROKU_APP_NAME1.git $CIRCLE_SHA1:master
