Google Authentication Bridge
============================

Google allow you to authenticate with their APIs with OAuth. That process can be a little tedious if you have to
do it over and over. Google Authentication Bridge allows you to authenticate with Google and will store the refresh
token in a file for subsequent use.

Usage
=====

With Google Drive https://github.com/gimite/google-drive-ruby

    auth = GoogleAuthenticationBridge::GoogleAuthentication.new(
      "https://docs.google.com/feeds/ https://docs.googleusercontent.com/ https://spreadsheets.google.com/feeds/",
      "client-id",
      "client-secret",
      "/path/to/token-file.yml"
    )
    # first time to create the refresh token
    token = auth.get_oauth2_access_token("auth-code")
    # subsequent times using the refresh token
    token = auth.get_oauth2_access_token
    session = GoogleDrive.login_with_oauth(token)

With Google API Client http://code.google.com/p/google-api-ruby-client/

    auth = GoogleAuthenticationBridge::GoogleAuthentication.new(
      "https://www.googleapis.com/auth/analytics.readonly",
      "client-id",
      "client-secret",
      "/path/to/token-file.yml"
    )
    # first time to create the refresh token
    token = auth.get_tokens("auth-code")
    # subsequent times using the refresh token
    token = auth.get_tokens

    client = Google::APIClient.new
    client.update_token!(token)

Rather than providing the credentials directly you can build the authentication object from a YAML configuration
file.

    auth = GoogleAuthenticationBridge::GoogleAuthentication.create_from_config_file(
      "scope",
      "/path/to/credentials.yml",
      "/path/to/token-file.yml"
    )