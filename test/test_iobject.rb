require 'rubygems'

require 'checkm'
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
      @manifest = Checkm::Manifest.new(@args['file'].read())
    end
    
    should "generate a valid manifest file with more than one line" do
      assert(@manifest.entries.length > 0, "Empty manifest?")
    end
    
    should "have a mrt-erc.txt entry, and it should be fetchable" do
      erc_pos = @manifest.entries.find_index { |entry| 
        entry.values[-2] == "mrt-erc.txt" }
      if erc_pos.nil?
        assert(false, "Could not find mrt-erc.txt file!")
      else
        erc_url = @manifest.entries[erc_pos].values[0]
        t = @iobject.start_server
        erc_lines = open(erc_url).read().lines().to_a
        t.join
      end
    end
  end
end
