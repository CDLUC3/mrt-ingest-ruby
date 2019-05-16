# Author::    Erik Hetzner  (mailto:erik.hetzner@ucop.edu)
# Copyright:: Copyright (c) 2011, Regents of the University of California

require 'digest/md5'

module Mrt
  module Ingest
    module MessageDigest
      class Base # :nodoc:
        attr_reader :value, :type
        def initialize(value, type)
          @value = value
          @type  = type
        end
      end

      # Represents a SHA256 digest suitable for a Checkm manifest.
      class SHA256 < Base
        def initialize(value)
          super(value, 'sha-256')
        end
      end

      # Represents an MD5 digest suitable for a Checkm manifest.
      class MD5 < Base
        def initialize(value)
          super(value, 'md5')
        end

        # Generate a digest from a file.
        def self.from_file(file)
          digest = Digest::MD5.new
          File.open(file.path, 'r') do |f|
            buff = ''
            digest << buff until f.read(1024, buff).nil?
          end
          Mrt::Ingest::MessageDigest::MD5.new(digest.hexdigest)
        end
      end

      # Represents a SHA1 digest suitable for a Checkm manifest.
      class SHA1 < Base
        def initialize(value)
          super(value, 'sha1')
        end
      end
    end
  end
end
