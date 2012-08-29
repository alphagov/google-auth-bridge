require "simplecov"
SimpleCov.start

require_relative "../lib/google_auth_bridge"
require "tempfile"

describe "Google Authentication Client" do
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
    File.open(@filename, 'w') {|f| f.write(@yaml_content) }
    @auth.load_token_from_file.should == "foo bar"
  end

  it "should raise a FileNotFoundError exception if the file is not there" do
    lambda {
      @auth.load_token_from_file
    }.should raise_error(GoogleAuthenticationBridge::FileNotFoundError)
  end

  it "should raise an InvalidFileFormatError exception if the file is badly formatted" do
    File.open(@filename, 'w') {|f| f.write("bad content") }
    lambda {
      @auth.load_token_from_file
    }.should raise_error(GoogleAuthenticationBridge::InvalidFileFormatError)
  end


  it "should raise an InvalidFileFormatError exception if the file does not contain refresh token" do
    File.open(@filename, 'w') {|f| f.write("---\n:refresh_token: \n") }
    lambda {
      @auth.load_token_from_file
    }.should raise_error(GoogleAuthenticationBridge::InvalidFileFormatError)
  end
end
