# OmniAuth::Cloudiap

OmniAuth strategy for Google Cloud IAP. Useful if you have application using omniauth-google-oauth2 and are moving it behind Google IAP.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "omniauth-cloudiap"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-cloudiap

## Usage

```ruby
use OmniAuth::Builder do
  provider :cloudiap
end
```

If you know application's aud, you can validate it:

```ruby
use OmniAuth::Builder do
  provider :cloudiap, aud: "/projects/9999999999999/global/backendServices/9999999999999999999"
end
```

If you don't need jwt verify,  you can skip it (not recommended)

```ruby
use OmniAuth::Builder do
  provider :cloudiap, skip_jwt_verify: true
end
```

In default, `env["omniauth.auth"]["info"]["name"]` is same as email. If you have usename dictionary, set :username_callback


```ruby
use OmniAuth::Builder do
  provider :cloudiap, username_callback: callback_object
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/holysugar/omniauth-cloudiap.
