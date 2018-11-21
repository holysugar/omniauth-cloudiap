require "test_helper"

class OmniAuth::Strategies::CloudiapTest < Minitest::Test
  include CloudiapTestHelper
  include Rack::Test::Methods
  attr_accessor :app

  def dummy_rack_env
    {
      "HTTP_X_GOOG_IAP_JWT_ASSERTION" => "dummy.jwt.string",
      "HTTP_X_GOOG_AUTHENTICATED_USER_EMAIL" => email_example,
      "HTTP_X_GOOG_AUTHENTICATED_USER_ID" => uid_example,
    }
  end

  def build_app(options = {})
    silence_warnings do
      self.app = Rack::Builder.app do
        use Rack::Session::Cookie
        use OmniAuth::Strategies::Cloudiap, options
        run lambda{|env|
          body = env.dig("omniauth.auth", "info").fetch_values("email", "name", "uid").join(":")
          [200, env, [body]]
        }
      end
    end
  end

  def setup
    build_app
  end

  def test_request_phase_only_redirects_callback_url
    result = get "/auth/cloudiap"
    assert { result.status == 302 }
    assert { result.location == "/auth/cloudiap/callback" }
  end

  def test_callback_phase
    with_stubbed_jwt_decode do
      result = get "/auth/cloudiap/callback", {}, dummy_rack_env
      assert { result.status == 200 }
      assert { result.body == "#{email_example}:#{email_example}:#{uid}" }
    end
  end

  def test_callback_phase_with_username_callback
    callback_object = {
      "1@example.com" => "1",
      "2@example.com" => "2",
      email_example => "myname",
    }
    build_app(username_callback: callback_object)

    with_stubbed_jwt_decode do
      result = get "/auth/cloudiap/callback", {}, dummy_rack_env
      assert { result.status == 200 }
      assert { result.body == "#{email_example}:myname:#{uid}" }
    end
  end

  def test_when_skip_jwt_verify
    build_app(skip_jwt_verify: true)

    result = get "/auth/cloudiap/callback", {}, dummy_rack_env
    assert { result.status == 200 }
  end

  def test_when_invalid_aud
    build_app(aud: "intended-aud")

    with_stubbed_jwt_decode do
      result = get "/auth/cloudiap/callback", {}, dummy_rack_env
      assert { result.status == 302 }
      assert { result.location == "/auth/failure?message=invalid_credentials&strategy=cloudiap" }
    end
  end

  def test_when_decode_error
    result = get "/auth/cloudiap/callback", {}, dummy_rack_env
    assert { result.status == 302 }
    assert { result.location == "/auth/failure?message=invalid_credentials&strategy=cloudiap" }
  end
end
