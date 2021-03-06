require 'digest/md5'

module Mrt
  module Ingest
    # Represents a component of an object to ingest. Either a #URI or a
    # #File.
    class Component # :nodoc:

      attr_reader :server, :uri

      def initialize(server, location, options)
        @server = server
        @name = options[:name]
        @digest = options[:digest]
        @mime_type = options[:mime_type]
        @size = options[:size]

        init_uri(location)
      end

      class << self
        def from_erc(server, erc)
          return Component.new(server, erc, name: 'mrt-erc.txt') if erc.is_a?(URI) || erc.is_a?(File)
          return from_hash(server, erc) if erc.is_a?(Hash)

          raise ArgumentError, 'Bad ERC supplied: must be a URI, File, or Hash'
        end

        def from_hash(server, erc_h)
          uri_str, path = server.add_file do |f|
            f.write("erc:\n")
            erc_h.each_pair { |k, v| f.write("#{k}: #{v}\n") }
          end

          digest = Mrt::Ingest::MessageDigest::MD5.from_file(File.new(path))
          Component.new(server, URI.parse(uri_str), name: 'mrt-erc.txt', digest: digest)
        end
      end

      def to_manifest_entry
        "#{@uri} | #{digest_type} | #{digest_value} | #{@size} | | #{@name} | #{@mime_type}\n"
      end

      def digest_type
        @digest && @digest.type
      end

      def digest_value
        @digest && @digest.value
      end

      private

      def file_like?(location)
        [File, Tempfile].any? { |c| location.is_a?(c) }
      end

      def init_uri(location)
        return init_from_file(location) if file_like?(location)
        return init_from_uri(location) if location.is_a?(URI)

        raise ArgumentError, "Trying to add a component that is not a File or URI: #{location}"
      end

      def init_from_file(file)
        @name = File.basename(file.path) if @name.nil?
        @uri = server.add_file(file)[0]
        @digest = Mrt::Ingest::MessageDigest::MD5.from_file(file) if @digest.nil?
        @size = File.size(file.path) if @size.nil?
      end

      def init_from_uri(uri)
        @name = File.basename(uri.to_s) if @name.nil?
        @uri = uri
      end
    end
  end
end
