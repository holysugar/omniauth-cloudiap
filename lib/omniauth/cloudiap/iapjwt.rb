require "jwt"
require "open-uri"
require "json"

module OmniAuth
  module Cloudiap
    class IAPJWT
      class InvalidAudError < Error; end

      def initialize(aud: nil)
        @required_aud = aud
      end

      def decode_with_validate(token)
        payload, = validate(token)
        { identifier: payload["sub"], email: payload["email"] }
      end

      def parse(token)
        JWT.decode token, nil, false
      end

      def jwk_keys
        @jwk_keys ||=
          begin
            url = "https://www.gstatic.com/iap/verify/public_key-jwk"
            URI.open(url) { |f| JSON.parse(f.read) } # rubocop:disable Security/Open
          end
      end

      def jwk_key(token)
        _, header = parse(token)
        jwk = jwk_keys["keys"]&.find { |k| k["kid"] == header["kid"] }

        curve_name =
          case jwk["crv"]
          when "P-256"
            "prime256v1"
          when "P-384"
            "secp384r1"
          when "P-521"
            "secp521r1"
          else
            fail AugumentError, "Unknown crv: #{jwk['crv']}"
          end
        x = Base64.urlsafe_decode64(jwk["x"])
        y = Base64.urlsafe_decode64(jwk["y"])

        key = OpenSSL::PKey::EC.new(curve_name)
        group = OpenSSL::PKey::EC::Group.new(curve_name)
        bn = OpenSSL::BN.new(Array(["04", x.unpack1("H*"), y.unpack1("H*")].join).pack("H*"), 2)
        key.public_key = OpenSSL::PKey::EC::Point.new(group, bn)
        key
      end

      def validate(token)
        iss = "https://cloud.google.com/iap"
        options = {
          algorithm: "ES256",
          verify_expiration: true,
          verify_iat: true,
          verify_aud: true,
          verify_iss: true,
          iss: iss,
        }
        payload, header = JWT.decode(token, jwk_key(token), true, options)
        if @required_aud
          validate_aud(@required_aud, payload["aud"])
        else
          validate_aud_format(payload["aud"])
        end
        [payload, header]
      end

      private

      def validate_aud(required_aud, aud)
        if required_aud != aud
          fail InvalidAudError, aud
        end
      end

      def validate_aud_format(aud)
        case aud
        when %r{/projects/\d+/apps/\d+}, %r{/projects/\d+/global/backendServices/\d+}
          # do nothing
        else
          fail InvalidAudError, aud
        end
      end
    end
  end
end
