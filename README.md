# NOTE: Readme Driven Development: May not do what the readme says yet.

## Content translator

A webservice to translate content using WebTranslateIt and keep track of mappings to local ids.

This app is designed with reliablity in mind. It will retry calls both to the client app and to the WTI service as needed.

This app follows the model of [gridlook](https://github.com/barsoom/gridlook) to keep things simple: one deployment per client project.

### Sending content changes to this app

Content is sent to this app by HTTP calls. Create and update is POST, destroy is DELETE.

These calls can be made multiple times without causing any problems, so design your app to continue retrying the requests until you get a 200 response (e.g. instead of a timeout).

    POST   /api/texts token=authtoken identifier="help_item_25" name="question" value="What is elixir?" locale=en
    DELETE /api/texts token=authtoken identifier="help_item_25"

See the configuration section for how to setup the token.

### Receiving changes from this app

Changes are sent back using a webhook. The webhook retries until it get's a 200 response or 3 hours has passed.

The message looks like:

      {
        identifier: "help_item_25",
        name: "question",
        text: "Vad är elixir?"
        locale: "sv",
      }

See the configuration section for how to setup webhook URLs.

## Configuration and deployment on heroku

    heroku apps:create some-content-translator --region eu --buildpack https://github.com/HashNuke/heroku-buildpack-elixir.git
    heroku config:set MIX_ENV=prod
    heroku config:set HOSTNAME=some-content-translator.herokuapp.com

    # no persistance yet, but soon, maybe redis
    #heroku addons:add rediscloud:25

    # NOTE: If you add more config variables, then also list them in elixir_buildpack.config
    heroku config:set SECRET_KEY_BASE=$(elixir -e "IO.puts :crypto.strong_rand_bytes(64) |> Base.encode64")
    heroku config:set AUTH_TOKEN=$(elixir -e "IO.puts Regex.replace(~r/[^a-zA-Z0-9]/, (:crypto.strong_rand_bytes(64) |> Base.encode64), \"\")")
    heroku config:set CLIENT_APP_WEBHOOK_URL=""https://example.com/api/somewhere?your_auth_token=123"
    heroku config:set WTI_PROJECT_ID=123

    git push heroku master

## TODO

### Minimal app

- [ ] Write configuration section docs
- [ ] handle text update and delete
- [ ] handle wti webhooks
  - [ ] be able to parse the request
  - [ ] post to the client app
- [ ] Authentication

### Reliable app

- [ ] Error reporting to honeybadger
- [ ] Reliability
  - [ ] be able to work though stored requests, e.g. background job, possibly boot up processes on app-boot, and otherwise just issue a process as needed when a request comes in.
  - [ ] be able to poll wti if this app has been during a webhook?
  - [ ] retry posting to the client app as the readme says

## Development

    mix deps.get
    mix test
    mix phoenix.server

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
