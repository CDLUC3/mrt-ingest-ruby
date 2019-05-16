# Author::    Erik Hetzner  (mailto:erik.hetzner@ucop.edu)
# Copyright:: Copyright (c) 2011, Regents of the University of California

require 'rubygems'

require 'test/unit'
require 'fakeweb'
require 'mocha'
require 'mrt/ingest'
require 'shoulda'

class TestRequest < Test::Unit::TestCase
  context "when creating a request" do
    setup do
    end

    should "not supplying a required parameter should raise an exception" do
      assert_raise(ArgumentError) do
        Mrt::Ingest::Request.new(profile: nil, submitter: "jd/John Doe", type: "file")
      end

      assert_raise(ArgumentError) do
        Mrt::Ingest::Request.new(profile: "demo_merritt", submitter: nil, type: "file")
      end

      assert_raise(ArgumentError) do
        Mrt::Ingest::Request.new(profile: "demo_merritt", submitter: "jd/John Doe", type: nil)
      end
    end
  end
end
