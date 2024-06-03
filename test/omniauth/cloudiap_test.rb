require "test_helper"

module OmniAuth
  class CloudiapTest < Minitest::Test
    include CloudiapTestHelper

    def setup
      @iapjwt = OmniAuth::Cloudiap::IAPJWT.new
      @remote_enabled = !!ENV["remote"]
    end

    def test_that_it_has_a_version_number
      assert { ::OmniAuth::Cloudiap::VERSION }
    end

    def test_jwk_keys
      skip unless @remote_enabled

      assert { @iapjwt.jwk_keys.is_a? Hash }
    end

    def test_jwk_key
      with_stubbed_jwt_decode do
        key = @iapjwt.jwk_key("dummy-token-string")
        assert { key.is_a? OpenSSL::PKey::EC }
      end
    end

    def test_validate
      with_stubbed_jwt_decode do
        payload, header = @iapjwt.validate("dummy-token-string")
        assert { payload == payload_example }
        assert { header == header_example }
      end
    end

    def test_validate_with_explicit_aud
      with_stubbed_jwt_decode do
        iapjwt = OmniAuth::Cloudiap::IAPJWT.new(aud: "/projects/0/globall/backendServices/0")
        assert_raises(OmniAuth::Cloudiap::IAPJWT::InvalidAudError) do
          iapjwt.validate("dummy-token-string")
        end
      end
    end

    def test_parse
      skip # FIXME
    end

    def test_decode_with_validate
      with_stubbed_jwt_decode do
        result = @iapjwt.decode_with_validate("dummy-token-string")
        assert { result[:identifier] == "accounts.google.com:999999999999999999999" }
        assert { result[:email] == "foo@example.com" }
      end
    end
  end
end
