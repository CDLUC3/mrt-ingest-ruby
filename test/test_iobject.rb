# Author::    Erik Hetzner  (mailto:erik.hetzner@ucop.edu)
# Copyright:: Copyright (c) 2011, Regents of the University of California

require 'rubygems'

require 'checkm'
require 'fakeweb'
require 'mocha'
require 'mrt/ingest'
require 'shoulda'
require 'open-uri'

class TestIObject < Test::Unit::TestCase
  def parse_object_manifest(iobject)
    req = iobject.mk_request("profile", "submitter")
    args = req.mk_args
    return Checkm::Manifest.new(args['file'].read())
  end

  def write_to_tempfile(content)
    tempfile = Tempfile.new('test_iobject')
    tempfile << content
    tempfile.open
    return tempfile
  end

  def get_uri_for_name(iobject, name)
    manifest = parse_object_manifest(iobject)
    return manifest.entries.find { |entry|
      entry.values[-2] == name
    }
  end

  context "when creating an iobject" do
    setup do
      @iobject = Mrt::Ingest::IObject.new
    end
    
    should "be able to add a URI component" do
      @iobject.add_component(URI.parse("http://example.org/file"))
    end

    should "not be able to add a non-URI component" do
      assert_raise(Mrt::Ingest::IngestException) do
        @iobject.add_component("http://example.org/file")
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
      @manifest = parse_object_manifest(@iobject)
      @erc_entry = get_uri_for_name(@iobject, "mrt-erc.txt")
    end
    
    should "generate a valid manifest file with more than one line" do
      assert(@manifest.entries.length > 0, "Empty manifest?")
    end
    
    should "have a mrt-erc.txt entry, and it should be fetchable" do
      if @erc_entry.nil?
        assert(false, "Could not find mrt-erc.txt file!")
      else
        @iobject.start_server()
        erc_lines = open(@erc_entry.values[0]).read().lines().to_a
        @iobject.stop_server()
      end
    end
  end

  ERC_CONTENT = <<EOS
who: John Doe
what: Something
when: now
EOS

  context "different ERC options" do
    should "be able to specify a file for ERC" do
      erc_tempfile = write_to_tempfile(ERC_CONTENT)
      iobject = Mrt::Ingest::IObject.new(:erc=>File.new(erc_tempfile.path))
      erc_entry = get_uri_for_name(iobject, "mrt-erc.txt")
      if erc_entry.nil?
        assert(false, "Could not find mrt-erc.txt file!")
      else
        iobject.start_server()
        assert_equal(ERC_CONTENT, open(erc_entry.values[0]).read())
        iobject.stop_server()
      end
    end
  end
  
  FILE_CONTENT = <<EOS
Hello, world!
EOS

  FILE_CONTENT_MD5 = "746308829575e17c3331bbcb00c0898b"

  context "serving local files" do
    should "be able to add a local file component" do
      iobject = Mrt::Ingest::IObject.new
      tempfile = write_to_tempfile(FILE_CONTENT)
      iobject.add_component(tempfile, {:name => "helloworld" })
      uri_entry = get_uri_for_name(iobject, "helloworld")
      erc_entry = get_uri_for_name(iobject, "mrt-erc.txt")
      manifest = parse_object_manifest(iobject)
      if uri_entry.nil?
        assert(false, "Could not find hosted file URI!")
      else
        iobject.start_server
        assert_equal(FILE_CONTENT, open(uri_entry.values[0]).read())
        iobject.stop_server()
      end
    end
  end
end
