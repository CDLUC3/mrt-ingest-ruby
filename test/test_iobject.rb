require 'rubygems'

require 'fakeweb'
require 'mocha'
require 'mrt_ingest'
require 'shoulda'

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
  end
end
