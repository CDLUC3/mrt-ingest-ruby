# Author::    Erik Hetzner  (mailto:erik.hetzner@ucop.edu)
# Copyright:: Copyright (c) 2011, Regents of the University of California

require 'rubygems'

require 'checkm'
require 'fakeweb'
require 'mocha'
require 'mrt/ingest'
require 'shoulda'
require 'open-uri'
require 'socket'

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

  def parse_erc(erc)
    arr = erc.lines.map do |line|
      md = line.chomp.match(/^([^:]+):\s*(.*)$/)
      [md[1], md[2]]
    end.flatten
    h = Hash[*arr]
    h.delete("erc")
    return h
  end

  def parse_erc_entry(erc_entry)
    return parse_erc(open(erc_entry.values[0]).read())
  end

  def check_erc_content(iobject, asserted_erc)
    erc_entry = get_uri_for_name(iobject, "mrt-erc.txt")
    if erc_entry.nil?
      assert(false, "Could not find mrt-erc.txt file!")
    else
      iobject.start_server()
      assert_equal(asserted_erc, parse_erc_entry(erc_entry))
      iobject.stop_server()
    end
  end

  context "an iobject" do
    setup do
      @iobject = Mrt::Ingest::IObject.new
    end
    
    should "be able to add a URI component" do
      @iobject.add_component(URI.parse("http://example.org/file"))
    end

    should "be able to add a URI component with prefetching, served locally" do
      @iobject.add_component(URI.parse("http://example.org/"), :prefetch=>true)
      manifest = parse_object_manifest(@iobject)
      manifest.entries.each do |entry|
        # check that all files are served locally
        uri = URI.parse(entry.values[0])
        assert_equal(Socket.gethostname, uri.host)
      end
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

  context "an iobject" do
    should "be able to specify a file for ERC" do
      erc_tempfile = write_to_tempfile(ERC_CONTENT)
      iobject = Mrt::Ingest::IObject.new(:erc=>File.new(erc_tempfile.path))
      check_erc_content(iobject, parse_erc(ERC_CONTENT))
    end
    
    should "be able to use a hash for ERC" do
      erc = { 
        "who" => "John Doe",
        "what" => "Something",
        "when" => "now" }
      iobject = Mrt::Ingest::IObject.new(:erc=>erc)
      check_erc_content(iobject, erc)
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
