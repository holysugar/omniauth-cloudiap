require "omniauth"
require "omniauth/cloudiap/iapjwt"

module OmniAuth
  module Strategies
    class Cloudiap
      include OmniAuth::Strategy

      class HTTPHeaderError < ::OmniAuth::Cloudiap::Error; end

      option :skip_jwt_verify
      option :aud

      # callback object from email address to user name
      # this callback must have interface [] (Hash, Proc, or class you define)
      # if none, use email for username
      option :username_callback

      attr_accessor :userinfo

      def request_phase
        redirect callback_path
      end

      def callback_phase
        if jwt_verify?
          begin
            self.userinfo = userinfo_from_jwt
          rescue => e
            return fail!(:invalid_credentials, e)
          end
        else
          self.userinfo = userinfo_from_http_header
        end

        super
      end

      def uid
        userinfo[:identifier] if userinfo
      end

      def info
        userinfo
      end

      private

      def jwt_verify?
        !options[:skip_jwt_verify]
      end

      def userinfo_from_jwt
        if token = env["HTTP_X_GOOG_IAP_JWT_ASSERTION"]
          payload, header = ::OmniAuth::Cloudiap::IAPJWT.new(aud: options[:aud]).validate(token)
          email = payload["email"]
          result = {
            identifier: payload["sub"],
            email: email,
            name: username_from_email(email),
            payload: payload.to_json,
          }
        else
          fail HTTPHeaderError, "No x-goog-iap-jwt-assertion Header"
        end
      end

      def userinfo_from_http_header
        email = env["HTTP_X_GOOG_AUTHENTICATED_USER_EMAIL"].sub(/^accounts.google.com:/, "")
        rsult = {
          identifier: env["HTTP_X_GOOG_AUTHENTICATED_USER_ID"],
          email: email,
          name: username_from_email(email),
        }
      end

      def username_from_email(email)
        if options[:username_callback] && options[:username_callback].respond_to?(:[])
          options[:username_callback][email]
        else
          email
        end
      end
    end
  end
end
