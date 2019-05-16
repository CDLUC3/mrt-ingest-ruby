require 'spec_helper'
require 'checkm'

module Mrt::Ingest
  describe IObject do

    before(:each) do
      # TODO: scope to hostname
      WebMock.allow_net_connect!
    end

    def parse_object_manifest(iobject)
      req = iobject.mk_request('profile', 'submitter')
      args = req.mk_args
      Checkm::Manifest.new(args['file'].read)
    end

    def write_to_tempfile(content)
      tempfile = Tempfile.new('test_iobject')
      tempfile << content
      tempfile.open
      tempfile
    end

    def get_uri_for_name(iobject, name)
      manifest = parse_object_manifest(iobject)
      manifest.entries.find do |entry|
        entry.values[-2] == name
      end
    end

    def parse_erc(erc)
      arr = erc.lines.map do |line|
        md = line.chomp.match(/^([^:]+):\s*(.*)$/)
        [md[1], md[2]]
      end.flatten
      h = Hash[*arr]
      h.delete('erc')
      h
    end

    def parse_erc_entry(erc_entry)
      parse_erc(open(erc_entry.values[0]).read)
    end

    def check_erc_content(iobject, asserted_erc)
      erc_entry = get_uri_for_name(iobject, 'mrt-erc.txt')
      expect(erc_entry).not_to be_nil
      iobject.start_server
      begin
        expect(parse_erc_entry(erc_entry)).to eq(asserted_erc)
      ensure
        iobject.stop_server
      end
    end

    describe 'with local ID' do
      before(:each) do
        @local_id = '10.1098/rstl.1665.0007'
        @iobject = IObject.new(local_identifier: @local_id)
      end

      it 'includes the local ID in the request' do
        request = @iobject.mk_request('profile', 'submitter')
        expect(request.local_identifier).to eq(@local_id)
      end
    end

    describe 'without local ID' do
      before(:each) do
        @iobject = IObject.new
      end

      it 'accepts a URI component' do
        uri = URI.parse('http://example.org/file')
        components = @iobject.add_component(uri)
        expect(components.size).to eq(1)
        expect(components[0].uri).to eq(uri)
      end

      it 'does not accept a string URI' do
        expect { @iobject.add_component('http://example.org/file') }.to raise_error(ArgumentError)
      end

      it 'makes a request' do
        req = @iobject.mk_request('profile', 'submitter')
        expect(req.profile).to eq('profile')
        expect(req.submitter).to eq('submitter')
      end
    end

    describe 'the created request' do
      before(:each) do
        @iobject = IObject.new
        @manifest = parse_object_manifest(@iobject)
        @erc_entry = get_uri_for_name(@iobject, 'mrt-erc.txt')
      end

      it 'should generate a valid manifest file' do
        expect(@manifest.entries).not_to be_empty
      end

      it 'should serve a valid mrt-erc.txt entry' do
        expect(@erc_entry).not_to be_nil
        @iobject.start_server
        begin
          open(@erc_entry.values[0]).read.lines.to_a
        ensure
          @iobject.stop_server
        end
      end

      describe :erc do
        ERC_CONTENT = <<~ERC.freeze
          who: John Doe
          what: Something
          when: now
        ERC

        it 'should accept a file' do
          erc_tempfile = write_to_tempfile(ERC_CONTENT)
          iobject = IObject.new(erc: File.new(erc_tempfile.path))
          check_erc_content(iobject, parse_erc(ERC_CONTENT))
        end

        it 'should accept a hash' do
          erc = {
            'who' => 'John Doe',
            'what' => 'Something',
            'when' => 'now'
          }
          iobject = Mrt::Ingest::IObject.new(erc: erc)
          check_erc_content(iobject, erc)
        end
      end

      describe 'local files' do
        FILE_CONTENT = <<~TXT.freeze
          Hello, world!
        TXT

        FILE_CONTENT_MD5 = '746308829575e17c3331bbcb00c0898b'.freeze

        it 'should support local files' do
          iobject = IObject.new
          tempfile = write_to_tempfile(FILE_CONTENT)
          iobject.add_component(tempfile, { name: 'helloworld' })
          uri_entry = get_uri_for_name(iobject, 'helloworld')
          erc_entry = get_uri_for_name(iobject, 'mrt-erc.txt')
          expect(erc_entry).not_to(be_nil)
          manifest = parse_object_manifest(iobject)
          expect(manifest).not_to(be_nil)
          expect(uri_entry).not_to be_nil
          iobject.start_server
          begin
            expect(open(uri_entry.values[0]).read).to eq(FILE_CONTENT)
          ensure
            iobject.stop_server
          end
        end
      end
    end

  end
end
