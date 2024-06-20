require 'digest/md5'

module Mrt
  module Ingest
    # Represents a component of an object to ingest. Either a #URI or a
    # #File.
    class Component # :nodoc:

      attr_reader :uri

      def initialize(location, options)
        @name = options[:name]
        @digest = options[:digest]
        @mime_type = options[:mime_type]
        @size = options[:size]

        init_uri(location)
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
        # @uri = server.add_file(file)[0]
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
