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
        JWT.decode(token, nil, true, algorithms: algorithms, jwks: jwks)
      end

      def jwk_keys
        url = "https://www.gstatic.com/iap/verify/public_key-jwk"
        URI.open(url) { |f| JSON.parse(f.read) } # rubocop:disable Security/Open
      end

      def jwks_loader(options)
        if options[:kid_not_found] && @cache_last_update < Time.now.to_i - 300
          logger.info("Invalidating JWK cache. #{options[:kid]} not found from previous cache")
          @cached_keys = nil
        end
        @cached_keys ||= begin # rubocop:disable Naming/MemoizedInstanceVariableName
          @cache_last_update = Time.now.to_i
          jwks = JWT::JWK::Set.new(jwk_keys)
          jwks.select! { |key| key[:use] == "sig" } # Signing Keys only
          jwks
        end
      end

      def default_jwt_decode_options
        {
          verify_expiration: true,
          verify_iat: true,
          verify_aud: true,
          verify_iss: true,
        }
      end

      def validate(token)
        iss = "https://cloud.google.com/iap"
        options = default_jwt_decode_options.merge(
          iss: iss,
          algorithm: "ES256",
          jwks: method(:jwks_loader),
        )

        payload, header = JWT.decode(token, nil, true, options)

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
