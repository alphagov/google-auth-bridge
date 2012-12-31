require "oauth2"
require "google/api_client"

module GoogleAuthenticationBridge
  class GoogleAuthentication
    GOOGLE_REDIRECT_URI = 'urn:ietf:wg:oauth:2.0:oob'

    def self.create_from_config_file(scope, file_name, token_file)
      config = load_file(file_name)
      client_id, client_secret = config[:google_client_id], config[:google_client_secret]
      raise InvalidFileFormatError.new(token_file) if client_id.nil? or client_secret.nil?
      GoogleAuthentication.new(
          scope,
          client_id,
          client_secret,
          token_file)
    end
    
    def self.load_file(file_name)
      YAML.load_file(file_name)
    end

    def initialize(scope, client_id, client_secret, token_file)
      @scope = scope
      @client_id = client_id
      @client_secret = client_secret
      @token_file = token_file
    end

    def token_file_exists?
      File.exists? @token_file
    end

    def get_tokens(authorization_code=nil)
      client = Google::APIClient.new
      setup_credentials(client, authorization_code)
      refresh_tokens(client)
    end

    def get_oauth2_access_token(authorization_code=nil)
      OAuth2::AccessToken.from_hash(get_oauth2_client, get_tokens(authorization_code))
    end

    def get_auth_url
      "https://accounts.google.com/o/oauth2/auth?response_type=code&scope=#{URI::encode(@scope)}&redirect_uri=#{GOOGLE_REDIRECT_URI}&client_id=#{URI::encode(@client_id)}"
    end

    def load_token_from_file
      raise FileNotFoundError.new(@token_file) unless token_file_exists?

      begin
        token_data = GoogleAuthentication.load_file(@token_file)
        token_data[:refresh_token] or raise
      rescue
        raise InvalidFileFormatError.new(@token_file)
      end
    end

    def save_token_to_file(refresh_token)
      raise InvalidTokenError.new(refresh_token) if refresh_token.nil?
      File.open(@token_file, 'w') { |f|
        f.write(YAML.dump({:refresh_token => refresh_token}))
      }
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
      if token_file_exists?
        client.authorization.update_token!(refresh_token: load_token_from_file)
        tokens = client.authorization.fetch_access_token
      else
        tokens = client.authorization.fetch_access_token
        save_token_to_file(tokens["refresh_token"])
      end
      tokens
    end

  end

  class Error < Exception
  end

  class FileNotFoundError < Error
    def initialize filename
      super "File not found #{filename}"
    end
  end

  class InvalidFileFormatError < Error
    def initialize filename
      super "Invalid token file format in '#{filename}'."
    end
  end

  class InvalidTokenError < Error
    def initialize token
      super "Invalid token '#{token.inspect}'."
    end
  end
end
