# Author::    Erik Hetzner  (mailto:erik.hetzner@ucop.edu)
# Copyright:: Copyright (c) 2011, Regents of the University of California

require 'mrt/ingest'
require 'tempfile'
require 'uri'

module Mrt
  module Ingest
    class Component
      def initialize(server, where, options)
        @name = options[:name]
        @digest = options[:digest]
        @mime_type = options[:mime_type]
        @size = options[:size]
        
        case where
        when File, Tempfile
          @name = File.basename(where.path) if @name.nil?
          @uri = server.add_file(where)
          if @digest.nil? then
            @digest = Mrt::Ingest::MessageDigest::MD5.from_file(where)
          end
          @size = File.size(where.path) if @size.nil?
        when URI
          @name = File.basename(where.to_s) if @name.nil?
          @uri = where
        else
          raise IngestException.new("Trying to add a component that is not a File or URI")
        end
        
      end
      
      def to_manifest_entry
        (digest_alg, digest_value) = if @digest.nil? then
                                       ['', '']
                                     else
                                       [@digest.type, @digest.value]
                                     end
        return "#{@uri} | #{digest_alg} | #{digest_value} | #{@size || ''} | | #{@name} | #{@mime_type || '' }\n"
      end
    end
    
    # An object ready for ingest into Merritt.
    class IObject
      
      attr_accessor :primary_identifier, :local_identifier, :erc, :erc_file

      def initialize(options={})
        @primary_identifier = options[:primary_identifier]
        @local_identifier = options[:local_identifier]
        @erc = options[:erc] || Hash.new
        @components = []
        @server = options[:server] || Mrt::Ingest::OneTimeServer.new
      end
      
      def add_component(where, options={})
        @components.push(Component.new(@server, where, options))
      end
      
      # Make a Mrt::Ingest::Request object for this mrt-object
      def mk_request(profile, submitter)
        erc_component = case @erc
                        when URI, File, Tempfile
                          Component.new(@server, @erc, :name => 'mrt-erc.txt')
                        when Hash
                          uri_str, path = @server.add_file do |f|
                            @erc.each do |k, v|
                              f.write("#{k}: #{v}\n")
                            end
                          end
                          Component.new(@server, 
                                        URI.parse(uri_str), 
                                        :name => 'mrt-erc.txt',
                                        :digest => Mrt::Ingest::MessageDigest::MD5.from_file(File.new(path)))
                        end
        manifest_file = Tempfile.new("mrt-ingest")
        mk_manifest(manifest_file, erc_component)
        # reset to beginning
        manifest_file.open
        return Mrt::Ingest::Request.
          new(:file               => manifest_file,
              :filename           => manifest_file.path.split(/\//).last,
              :type               => "object-manifest",
              :submitter          => submitter,
              :profile            => profile,
              :primary_identifier => @primary_identifier)
      end

      def start_server
        return @server.start_server()
      end

      def join_server
        return @server.join_server()
      end

      def stop_server
        return @server.stop_server()
      end
        
      def mk_manifest(manifest, erc_component)
        manifest.write("#%checkm_0.7\n")
        manifest.write("#%profile http://uc3.cdlib.org/registry/ingest/manifest/mrt-ingest-manifest\n")
        manifest.write("#%prefix | mrt: | http://uc3.cdlib.org/ontology/mom#\n")
        manifest.write("#%prefix | nfo: | http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#\n")
        manifest.write("#%fields | nfo:fileUrl | nfo:hashAlgorithm | nfo:hashValue | nfo:fileSize | nfo:fileLastModified | nfo:fileName | mrt:mimeType\n")
        @components.each { |c|
          manifest.write(c.to_manifest_entry)
        }
        manifest.write(erc_component.to_manifest_entry)
        manifest.write("#%EOF\n")
      end
      
      def start_ingest(client, profile, submitter)
        request = mk_request(profile, submitter)
        start_server
        @response = client.ingest(request)
        return @response
      end

      def finish_ingest
        join_server
      end
    end
  end
end
