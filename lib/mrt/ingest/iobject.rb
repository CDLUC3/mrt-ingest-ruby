# Author::    Erik Hetzner  (mailto:erik.hetzner@ucop.edu)
# Copyright:: Copyright (c) 2011, Regents of the University of California

require 'mrt/ingest'
require 'tempfile'
require 'uri'
require 'open-uri'
require 'digest/md5'

module Mrt
  module Ingest
    # Represents a component of an object to ingest. Either a #URI or a
    # #File.
    class Component # :nodoc:
      def initialize(server, where, options)
        @name = options[:name]
        @digest = options[:digest]
        @mime_type = options[:mime_type]
        @size = options[:size]
        # @prefetch = options[:prefetch] || false
        @prefetch = false # TODO: remove prefetch code

        case where
        when File, Tempfile
          @name = File.basename(where.path) if @name.nil?
          @uri = server.add_file(where)[0]
          @digest = Mrt::Ingest::MessageDigest::MD5.from_file(where) if @digest.nil?
          @size = File.size(where.path) if @size.nil?
        when URI
          @name = File.basename(where.to_s) if @name.nil?
          if @prefetch
            digest = Digest::MD5.new
            @uri, ignore = server.add_file do |f|
              open(where, (options[:prefetch_options] || {})) do |u|
                while (buff = u.read(1024))
                  f << buff
                  digest << buff
                end
              end
            end
            @digest = Mrt::Ingest::MessageDigest::MD5.new(digest.hexdigest)
          else
            @uri = where
          end
        else
          raise IngestException, 'Trying to add a component that is not a File or URI'
        end
      end

      def to_manifest_entry
        (digest_alg, digest_value) = if @digest.nil?
                                       ['', '']
                                     else
                                       [@digest.type, @digest.value]
                                     end
        "#{@uri} | #{digest_alg} | #{digest_value} | #{@size || ''} | | #{@name} | #{@mime_type || ''}\n"
      end
    end

    # An object prepared for ingest into Merritt.
    class IObject

      attr_accessor :primary_identifier, :local_identifier, :erc

      # Options can have the keys :primary_identifier,
      # :local_identifier, :server, or :erc. :erc can be a #File, #Uri
      # or a #Hash of metadata. :server is a #OneTimeServer.
      def initialize(options = {})
        @primary_identifier = options[:primary_identifier]
        @local_identifier = options[:local_identifier]
        @erc = options[:erc] || {}
        @components = []
        @server = options[:server] || Mrt::Ingest::OneTimeServer.new
      end

      # Add a component to the object. where can be either a #URI or a
      # #File. Options is a hash whose keys may be :name, :digest,
      # :mime_type, or :size. If :digest is supplied, it must be a
      # subclass of Mrt::Ingest::MessageDigest::Base. If where is a
      # #File, it will be hosted on an embedded web server.
      def add_component(where, options = {})
        @components.push(Component.new(@server, where, options))
      end

      # Make a Mrt::Ingest::Request object for this mrt-object
      def mk_request(profile, submitter)
        erc_component = case @erc
                        when URI, File, Tempfile
                          Component.new(@server, @erc, name: 'mrt-erc.txt')
                        when Hash
                          uri_str, path = @server.add_file do |f|
                            f.write("erc:\n")
                            @erc.each_pair do |k, v|
                              f.write("#{k}: #{v}\n")
                            end
                          end
                          Component.new(@server,
                                        URI.parse(uri_str),
                                        name: 'mrt-erc.txt',
                                        digest: Mrt::Ingest::MessageDigest::MD5.from_file(File.new(path)))
                        else
                          raise IngestException, 'Bad ERC supplied: must be a URI, File, or Hash'
                        end
        manifest_file = Tempfile.new('mrt-ingest')
        mk_manifest(manifest_file, erc_component)
        # reset to beginning
        manifest_file.open
        Mrt::Ingest::Request
          .new(file: manifest_file,
               filename: manifest_file.path.split(%r{/}).last,
               type: 'object-manifest',
               submitter: submitter,
               profile: profile,
               local_identifier: @local_identifier,
               primary_identifier: @primary_identifier)
      end

      def start_server # :nodoc:
        @server.start_server
      end

      def join_server # :nodoc:
        @server.join_server
      end

      def stop_server # :nodoc:
        @server.stop_server
      end

      def mk_manifest(manifest, erc_component) # :nodoc:
        manifest.write("#%checkm_0.7\n")
        manifest.write("#%profile http://uc3.cdlib.org/registry/ingest/manifest/mrt-ingest-manifest\n")
        manifest.write("#%prefix | mrt: | http://uc3.cdlib.org/ontology/mom#\n")
        manifest.write("#%prefix | nfo: | http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#\n")
        manifest.write("#%fields | nfo:fileUrl | nfo:hashAlgorithm | nfo:hashValue | nfo:fileSize | nfo:fileLastModified | nfo:fileName | mrt:mimeType\n")
        @components.each do |c|
          manifest.write(c.to_manifest_entry)
        end
        manifest.write(erc_component.to_manifest_entry)
        manifest.write("#%EOF\n")
      end

      # Begin an ingest on the given client, with a profile and
      # submitter.
      def start_ingest(client, profile, submitter)
        request = mk_request(profile, submitter)
        start_server
        @response = client.ingest(request)
        @response
      end

      # Wait for the ingest of this object to finish.
      def finish_ingest
        # XXX Right now we only join the hosting server; in the future
        # we will check the status via the ingest server.
        join_server
      end
    end
  end
end
