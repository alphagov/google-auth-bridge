require "simplecov"
SimpleCov.start

require_relative "../lib/google_auth_bridge"
require "tempfile"

module GoogleAuthenticationBridge
  class GoogleAuthentication
    attr_reader :client_id, :client_secret
  end
end

describe "Google Authentication Client" do
  describe "Config file" do

    before(:each) do
      @filename = "/tmp/config-test.yaml"
    end

    after(:each) do
      File.unlink(@filename) if File.exist?(@filename)
    end

    it "should read the client id and the client secret" do
      File.open(@filename, "w") { |f| f.write("---\n:google_client_id: foo bar\n:google_client_secret: very secret\n") }
      auth = GoogleAuthenticationBridge::GoogleAuthentication.create_from_config_file(nil, @filename, nil)

      auth.client_id.should == "foo bar"
      auth.client_secret.should == "very secret"
    end

    it "should raise an error when client id is missing" do
      File.open(@filename, "w") { |f| f.write("---\n:google_client_secret: very secret\n") }

      -> {
        GoogleAuthenticationBridge::GoogleAuthentication.create_from_config_file(nil, @filename, nil)
      }.should raise_error(GoogleAuthenticationBridge::InvalidFileFormatError)

    end

    it "should raise an error when client secret is missing" do
      File.open(@filename, "w") { |f| f.write("---\n:google_client_secret: very secret\n") }

      -> {
        GoogleAuthenticationBridge::GoogleAuthentication.create_from_config_file(nil, @filename, nil)
      }.should raise_error(GoogleAuthenticationBridge::InvalidFileFormatError)

    end

    it "should raise an error when config file is missing" do
      -> {
        GoogleAuthenticationBridge::GoogleAuthentication.create_from_config_file(nil, @filename, nil)
      }.should raise_error
    end

  end

  describe "Token file" do
    before(:each) do
      @filename = "/tmp/test.token"
      @auth = GoogleAuthenticationBridge::GoogleAuthentication.new(nil, nil, nil, @filename)
      @yaml_content = "---\n:refresh_token: foo bar\n"
      @yaml_pattern = /---\s?\n:refresh_token: foo bar\n/
    end

    after(:each) do
      File.delete(@filename) if File.exists? @filename
    end

    it "should save refresh token to file as yaml" do
      File.exists?(@filename).should be_false
      @auth.save_token_to_file("foo bar")
      File.exists?(@filename).should be_true
      File.read(@filename).should match(@yaml_pattern)
    end

    it "should raise an InvalidTokenError exception if the refresh token is nil" do
      lambda {
        @auth.save_token_to_file(nil)
      }.should raise_error(GoogleAuthenticationBridge::InvalidTokenError)
    end

    it "should load refresh token from yaml file" do
      File.open(@filename, 'w') { |f| f.write(@yaml_content) }
      @auth.load_token_from_file.should == "foo bar"
    end

    it "should raise a FileNotFoundError exception if the file is not there" do
      lambda {
        @auth.load_token_from_file
      }.should raise_error(GoogleAuthenticationBridge::FileNotFoundError)
    end

    it "should raise an InvalidFileFormatError exception if the file is badly formatted" do
      File.open(@filename, 'w') { |f| f.write("bad content") }
      lambda {
        @auth.load_token_from_file
      }.should raise_error(GoogleAuthenticationBridge::InvalidFileFormatError)
    end


    it "should raise an InvalidFileFormatError exception if the file does not contain refresh token" do
      File.open(@filename, 'w') { |f| f.write("---\n:refresh_token: \n") }
      lambda {
        @auth.load_token_from_file
      }.should raise_error(GoogleAuthenticationBridge::InvalidFileFormatError)
    end
  end
end
