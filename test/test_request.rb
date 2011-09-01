require 'rubygems'

require 'fakeweb'
require 'mocha'
require 'mrt_ingest'
require 'shoulda'

class TestRequest < Test::Unit::TestCase
  context "when creating a request" do
    setup do
    end
    
    should "not supplying a required parameter should raise an exception" do
      assert_raise(Mrt::Ingest::RequestException) do
        Mrt::Ingest::Request.
          new(:submitter => "jd/John Doe",
              :type      => "file")
      end

      assert_raise(Mrt::Ingest::RequestException) do
        Mrt::Ingest::Request.
          new(:profile => "demo_merritt",
              :type    => "file")
      end

      assert_raise(Mrt::Ingest::RequestException) do
        Mrt::Ingest::Request.
          new(:profile   => "demo_merritt",
              :submitter => "jd/John Doe")
      end
    end
  end
end
