require "oauth2"
require "google/api_client"

module GoogleAuthenticationBridge
  class GoogleAuthentication
    GOOGLE_TOKENS_FILENAME = "tokens"
    GOOGLE_REDIRECT_URI = 'urn:ietf:wg:oauth:2.0:oob'

    def self.create_from_config_file(scope, file_name)
      config = YAML.load_file(file_name)
      GoogleAuthentication.new(
          scope,
          config["google_client_id"],
          config["google_client_secret"])
    end

    def initialize(scope, client_id, client_secret)
      @scope = scope
      @client_id = client_id
      @client_secret = client_secret
    end

    def get_tokens(authorization_code=nil)
      client = Google::APIClient.new
      setup_credentials(client, authorization_code)
      refresh_tokens(client)
    end

    def get_oauth2_access_token(authorization_code=nil)
      OAuth2::AccessToken.from_hash(get_oauth2_client, get_tokens(authorization_code))
    end

    private
    def get_oauth2_client
      OAuth2::Client.new(@client_id, @client_secret,
	site: "https://accounts.google.com",
	token_url: "/o/oauth2/token",
	authorize_url: "/o/oauth2/auth"
      )
    end

    def setup_credentials(client, code)
      authorization = client.authorization
      authorization.client_id = @client_id
      authorization.client_secret = @client_secret
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
