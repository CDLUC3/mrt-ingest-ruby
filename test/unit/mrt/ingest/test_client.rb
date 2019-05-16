# Author::    Erik Hetzner  (mailto:erik.hetzner@ucop.edu)
# Copyright:: Copyright (c) 2011, Regents of the University of California

require 'rubygems'

require 'test/unit'
require 'checkm'
require 'fakeweb'
require 'mocha'
require 'mrt/ingest'
require 'shoulda'
require 'open-uri'

class TestClient < Test::Unit::TestCase
  context "creating a client" do
    should "be able to create an ingest client" do
      client = Mrt::Ingest::Client.new("http://example.org/ingest")
      assert_instance_of(Mrt::Ingest::Client, client)
    end

    should "be able to create an ingest client with login credentials" do
      client = Mrt::Ingest::Client.new("http://example.org/ingest", "me", "secret")
      assert_instance_of(Mrt::Ingest::Client, client)
    end
  end
  
  context "ingest clients" do
    setup do
      @client = Mrt::Ingest::Client.new("http://example.org/ingest", "me", "secret")
      @iobject = Mrt::Ingest::IObject.new
      @ingest_req = @iobject.mk_request("profile", "submitter")
    end

    should "should create a good rest client request" do
      rest_req = @client.mk_rest_request(@ingest_req)
      assert_equal("me", rest_req.user)
      assert_equal("secret", rest_req.password)
    end
  end
end
