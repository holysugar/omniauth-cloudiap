$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "omniauth/cloudiap"
require "minitest/autorun"
require "minitest/power_assert"
require "rack/test"
require "rack/session"

module CloudiapTestHelper

  def email_example
    "foo@example.com"
  end

  def uid
    "999999999999999999999"
  end

  def uid_example
    "accounts.google.com:#{uid}"
  end

  def payload_example
    {
      "iss"   => "https://cloud.google.com/iap",
      "sub"   => uid_example,
      "email" => email_example,
      "aud"   => "/projects/9999999999999/global/backendServices/9999999999999999999",
      "exp"   => 1541127981,
      "iat"   => 1541127381,
    }
  end

  def header_example
    {
      "alg" => "ES256",
      "typ" => "JWT",
      "kid" => "FAWt5w",
    }
  end

  def with_stubbed_jwt_decode
    JWT.stub(:decode, [payload_example, header_example]) do
      yield
    end
  end

  def silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end
end
