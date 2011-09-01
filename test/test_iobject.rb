require 'rubygems'

require 'fakeweb'
require 'mocha'
require 'mrt_ingest'
require 'shoulda'
require 'open-uri'

class TestIObject < Test::Unit::TestCase
  context "when creating an iobject" do
    setup do
      @iobject = Mrt::Ingest::IObject.new
    end
    
    should "be able to add a URI component" do
      @iobject.add_component(URI.parse("http://example.org/file"), "file")
    end

    should "not be able to add a non-URI component" do
      assert_raise(Mrt::Ingest::IngestException) do
        @iobject.add_component("http://example.org/file", "file")
      end
    end
    
    should "be able to make a request" do
      req = @iobject.mk_request("profile", "submitter")
      assert_equal("profile", req.profile)
      assert_equal("submitter", req.submitter)
    end
  end
  
  context "the created request" do
    setup do
      @iobject = Mrt::Ingest::IObject.new
      @req = @iobject.mk_request("profile", "submitter")
      @args = @req.mk_args
      @manifest = @args['file'].read().lines().to_a
    end
    
    should "generate a valid manifest file" do
      assert_equal("#%checkm_0.7\n", @manifest[0])
    end
    
    should "have a mrt-erc.txt entry, and it should be fetchable" do
      erc_url = nil
      catch :done do
        @manifest.each do |line|
          parts = line.split(/\s+/)
          if parts[-1] == "mrt-erc.txt" then
            erc_url = parts[0]
            assert(true)
            throw :done
          end
        end
        assert(false, "Could not find mrt-erc.txt file!")
      end
      t = Thread.new do
        @iobject.start_server
      end
      open(erc_url).read()
      t.join
    end
  end
end
