$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "omniauth/cloudiap"
require "minitest/autorun"
require "minitest/power_assert"
require "minitest/stub_any_instance"
require "rack/test"
require "rack/session"

OmniAuth.config.request_validation_phase = nil

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
      "iss" => "https://cloud.google.com/iap",
      "sub" => uid_example,
      "email" => email_example,
      "aud" => "/projects/9999999999999/global/backendServices/9999999999999999999",
      "exp" => 1541127981,
      "iat" => 1541127381,
    }
  end

  def header_example
    {
      "alg" => "ES256",
      "typ" => "JWT",
      "kid" => "JJAn2A",
    }
  end

  def jwk_keys_example
    JSON.parse(<<~JSON)
      {
         "keys" : [
            {
               "alg" : "ES256",
               "crv" : "P-256",
               "kid" : "D-V_8g",
               "kty" : "EC",
               "use" : "sig",
               "x" : "B9kXAbjuRMZo9-FxFcdh9KLBxjNWk7xL45XVuHiNWho",
               "y" : "IQA95Vx2d7P0P_unVyYk8ckDgIUN9q8Po2qATZHGrFo"
            },
            {
               "alg" : "ES256",
               "crv" : "P-256",
               "kid" : "JJAn2A",
               "kty" : "EC",
               "use" : "sig",
               "x" : "Uv-vWDcG5tlZiX76OOtf5WAuptVmNZ9A08UiRIph4HQ",
               "y" : "A6a3umDIQC76754v8D--obg7BuCaaWcNk2FbS74shBw"
            }
         ]
      }
    JSON
  end

  def with_stubbed_jwt_decode(&block)
    OmniAuth::Cloudiap::IAPJWT.stub_any_instance(:jwk_keys, jwk_keys_example) do
      JWT.stub(:decode, [payload_example, header_example], &block)
    end
  end

  def silence_warnings
    old_verbose = $VERBOSE
    $VERBOSE = nil
    yield
  ensure
    $VERBOSE = old_verbose
  end
end
