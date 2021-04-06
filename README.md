**Status**: Used in production.
Based on some evaluation from Maintenace team, it was decied to not develop further. 
Tests don’t accurately reflect whether it works and it a job processor not longer maintained.
Open for re-evaluation.
https://auctionet.slack.com/archives/CF9SAN79V/p1617694713026100

[CircleCi](https://circleci.com/gh/barsoom/content_translator)

## Content translator

A webservice to translate content using WebTranslateIt and keep track of mappings to local ids.

This app is designed with reliability in mind. It will retry calls both to the client app and to the WTI service as needed.

This app follows the model of [gridlook](https://github.com/barsoom/gridlook) to keep things simple: one deployment per client project.

### Sending content changes to this app

Content is sent to this app by HTTP calls. Create and update is POST, destroy is DELETE.

These calls can be made multiple times without causing any problems, so design your app to continue retrying the requests until you get a 200 response (e.g. instead of a timeout).

    POST   /api/texts token=authtoken key="help_item_25: question" value="What is elixir?" locale=en
    DELETE /api/texts token=authtoken key="help_item_25: question"

See the configuration section for how to set up the token.

### Receiving changes from this app

Changes are sent back using a webhook. The webhook retries until it gets a 200 response or a few minutes has passed, at which point you can manually trigger more retries (see more on error handling below). No update sent though this app is lost unless you manually choose to delete it.

The value of `payload` is form-encoded JSON.

Which looks like this when not form-encoded:

      {"key":"help_item_25: question","value":"Vad är elixir?","locale":"sv"}

In Rails you can do this:

      payload = JSON.parse(params[:payload])
      payload["name"] # => "question"

See the configuration section for how to set up webhook URLs.

### Linking to a search on WTI through this app

When you visit a link like this:

    /search?query=somekey&from=en&to=de

You will be redirected to a WTI search for the `WTI_PROJECT_ID`.

## Set up

### Set up a project in WebTranslateIt

[Create a project](https://webtranslateit.com/en/projects/new) and:

0. Set up a source language
0. Add languages you want to translate to

### Deploy this app to heroku

This app can be run on a free Heroku dyno since it boots fast enough to process new requests from WTI without timeouts. Usually you don't have new translations coming in all day long either, so it can sleep most of the time.

    heroku apps:create some-content-translator --region eu --buildpack https://github.com/HashNuke/heroku-buildpack-elixir.git
    heroku labs:enable runtime-dyno-metadata
    heroku config:set MIX_ENV=prod
    heroku config:set HOSTNAME=some-content-translator.herokuapp.com

    # NOTE: If you add more config variables, then also list them in elixir_buildpack.config
    heroku config:set SECRET_KEY_BASE=$(elixir -e "IO.puts :crypto.strong_rand_bytes(64) |> Base.encode64")
    heroku config:set AUTH_TOKEN=$(elixir -e "IO.puts Regex.replace(~r/[^a-zA-Z0-9]/, (:crypto.strong_rand_bytes(64) |> Base.encode64), \"\")")
    heroku config:set CLIENT_APP_WEBHOOK_URL="https://example.com/api/somewhere?your_auth_token=123"
    heroku config:set WTI_PROJECT_ID=123
    heroku config:set WTI_PROJECT_TOKEN=token # must be the read-write token
    heroku config:set HONEYBADGER_API_KEY=your-api-key

    heroku addons:add rediscloud:25

    git push heroku master

### Configure check that it works

0. Configure the webhook url in WTI to something like `https://YOUR_APP_NAME.herokuapp.com/api/wti_webhook?token=the-auth-token-for-this-app`
0. Configure the client app to send content to this app
0. Change something in your client app, see that it appears in WTI
0. Translate something in WTI and see if the content is updated in your app

## What to do when an error occurs with the sync

If the sync fails, either from the application to WTI, or the other way around, then you will have to decide what to do about the failed jobs.

If the error is "req_timedout", it should be safe to retry (TODO: improve handling of timeouts so we don't have to). For other types of errors, figure it out and update these docs.

These are some helpful commands:

    # Open a development console
    iex -S mix

    # Open a production console
    heroku run iex -S mix

    # List all failed jobs
    iex> Toniq.failed_jobs
    
    # See the error of all failed jobs
    Toniq.failed_jobs |> Enum.map &(&1.error)

    # Pick out the first failed job
    iex> job = Toniq.failed_jobs |> hd
    
    # Inspect job attributes
    iex> job.arguments
    iex> job.worker
    iex> job.error

    # Retry a job
    iex> Toniq.retry(job)

    # Delete a job
    iex> Toniq.delete(job)

    # Retry all jobs
    iex> Toniq.failed_jobs |> Enum.each fn (job) -> Toniq.retry(job) end

    # See raw Redis data
    Process.whereis(:toniq_redis) |> Exredis.Api.keys("*")

By the time you read this there might be an web based admin UI for toniq you could use instead, [check the project](https://github.com/joakimk/toniq).

## Development

    # Redis is required for tests/server to run. Start it with
    redis-server
    # (If you're an Auctionet developer using devbox, it should be started automatically in the background by the `dev` command – see the dev.yml file.)

    mix deps.get
    mix test
    mix phoenix.server

### Maintenance

To keep this app up-to-date, periodically update dependencies, run tests, push, deploy, and manually check that it works too.

    mix deps.update [dependency]
    # or: mix deps.update --all

    mix test

Also update erlang and elixir in elixir\_buildpack.config as new stable versions are released.

### Gotchas

All strings are stripped of whitespace at the end because WTI won't accept strings ending in newlines.

### Seeing 406 errors from WTI?

WTI does some validation. One example of this is that the translated text must end with a newline if the source test does. One way of getting around this is to not let the user edit the translated text in the source system. If all translations are done in WTI the user has to deal with it's validations before being able to save.

I've asked the WTI maintainer to return the actual validation error in the API response. At the time of writing I belive he has, but I haven't had the time to check.

## TODO

### Before we can use and support this internally

- [x] Add instructions for what to do when an error occurs, how to retry jobs, etc.
- [x] Add instructions for keeping this app's dependencies up to date
- [x] Add app to code review tool
- [x] Cleanup this readme
- [x] Ask for an initial review of the entire thing, anything confusing, etc.
- [x] Configure internal notifications for honeybadger errors
- [x] Remove anything from readme that isn't in the tool and remove readme-driven-dev tag
- [x] When devs has gotten a chance to look at it: Invite more people to use it for a trial period
- [x] After feedback: Release 1.0

### Prio

- [ ] ensure the source language is always posted first to avoid validation issues
  - redoing the API as posting an entire string with all translations would fix this
  - **note** It might just work most of the time, and when it does not retries will probably work around it. Haven't seen any errors from this in a while.

### More

- [ ] Check if the errors that are returned for WTI validations are sent to honeybadger in a meaningful way
- [ ] Use the official honeybadger client (mine works, but it's probably not as fully featured)
- [ ] Figure out testing for API clients
- [ ] Explore disabling validations for all things we post to WTI. See docs https://webtranslateit.com/en/docs/api/translation/#parameters
  - Could remove some workarounds, but could also make tests uneditable in WTI
- [ ] endpoint.ex has signing_salt and encryption_salt secrets, not used, but should not be there
- [ ] See if more metadata could be provided in keys, e.g. category of a thing so you can filter translations (req by nicolas)
- [ ] Add step to readme for removing the default postgres DB so you won't think it might be used
- [ ] Screenshots of WTI in readme, diff handling, etc
- [ ] Show app status on internal dashboard
- [ ] Open source generic parts of the ruby client
- [ ] Don't push anything to WTI that hasn't changed (but if this app does not keep any state that could be hard, could leave that up to the client app)
- [ ] Would it be easy to setup a Dockerfile and post this to dockerhub? Easy alternative to heroku.
  - How to handle config?
- [ ] Show background job stats on pages#index or use a future toniq admin web ui

### Credits and license

By [Barsoom](http://barsoom.se) under the MIT license:

>  Copyright © 2015 Barsoom AB
>
>  Permission is hereby granted, free of charge, to any person obtaining a copy
>  of this software and associated documentation files (the "Software"), to deal
>  in the Software without restriction, including without limitation the rights
>  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
>  copies of the Software, and to permit persons to whom the Software is
>  furnished to do so, subject to the following conditions:
>
>  The above copyright notice and this permission notice shall be included in
>  all copies or substantial portions of the Software.
>
>  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
>  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
>  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
>  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
>  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
>  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
>  THE SOFTWARE.
