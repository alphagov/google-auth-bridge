require 'bundler/setup'
Bundler.require

module GoogleAuthenticationBridge
  class GoogleAuthentication
    GOOGLE_TOKENS_FILENAME = "tokens"
    GOOGLE_REDIRECT_URI = 'urn:ietf:wg:oauth:2.0:oob'

    GOOGLE_CLIENT_ID = '1054017153726.apps.googleusercontent.com'
    GOOGLE_CLIENT_SECRET = 'eMFsc8LU3ZGrRFG93WfQCnD3'

    def initialize(scope)
      @scope = scope
    end

    def get_tokens(authorization_code)
      client = Google::APIClient.new
      setup_credentials(client, authorization_code)
      refresh_tokens(client)
    end

    def get_oauth2_access_token(authorization_code)
      OAuth2::AccessToken.from_hash(get_oauth2_client, get_tokens(authorization_code))
    end

    private
    def get_oauth2_client
      OAuth2::Client.new(GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET,
	site: "https://accounts.google.com",
	token_url: "/o/oauth2/token",
	authorize_url: "/o/oauth2/auth"
      )
    end

    def setup_credentials(client, code)
      authorization = client.authorization
      authorization.client_id = GOOGLE_CLIENT_ID
      authorization.client_secret = GOOGLE_CLIENT_SECRET
      authorization.scope = @scope
      authorization.redirect_uri = GOOGLE_REDIRECT_URI
      authorization.code = code
    end

    def refresh_tokens(client)
      if File.exist? GOOGLE_TOKENS_FILENAME then
	client.authorization.update_token!(Tokens::load_from_file)
	tokens = client.authorization.fetch_access_token
      else
	tokens = client.authorization.fetch_access_token
	Tokens::save_to_file(tokens["refresh_token"])
      end
      tokens
    end

    public
    class Tokens
      def self.save_to_file(refresh_token)
	File.open(GoogleAuthentication::GOOGLE_TOKENS_FILENAME, 'w') { |f|
	  f.write({"refresh_token" => refresh_token })
	}
      end

      def self.load_from_file
	eval(open(GoogleAuthentication::GOOGLE_TOKENS_FILENAME).lines.reduce)
      end
    end
  end
end
