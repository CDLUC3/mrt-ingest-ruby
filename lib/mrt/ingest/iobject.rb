# Author::    Erik Hetzner  (mailto:erik.hetzner@ucop.edu)
# Copyright:: Copyright (c) 2011, Regents of the University of California

require 'tempfile'
require 'uri'
require 'open-uri'
require 'digest/md5'

module Mrt
  module Ingest

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
        manifest_file = Tempfile.new('mrt-ingest')
        erc_component = Component.from_erc(@server, @erc)
        mk_manifest(manifest_file, erc_component)
        # reset to beginning
        manifest_file.open
        new_request(manifest_file, profile, submitter)
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

      # rubocop:disable Metrics/LineLength
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
      # rubocop:enable Metrics/LineLength

      # Begin an ingest on the given client, with a profile and
      # submitter.
      def start_ingest(client, profile, submitter)
        request = mk_request(profile, submitter)
        start_server
        @response = client.ingest(request)
      end

      # Wait for the ingest of this object to finish.
      def finish_ingest
        # XXX Right now we only join the hosting server; in the future
        # we will check the status via the ingest server.
        join_server
      end

      private

      def new_request(manifest_file, profile, submitter)
        Mrt::Ingest::Request.new(
          file: manifest_file,
          filename: manifest_file.path.split(%r{/}).last,
          type: 'object-manifest',
          submitter: submitter,
          profile: profile,
          local_identifier: @local_identifier,
          primary_identifier: @primary_identifier
        )
      end

    end
  end
end
