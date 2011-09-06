# Author::    Erik Hetzner  (mailto:erik.hetzner@ucop.edu)
# Copyright:: Copyright (c) 2011, Regents of the University of California

require 'digest/md5'

module Mrt
  module Ingest
    module MessageDigest
      class Base
        attr_reader :value
        def initialize(value)
          @value = value
        end
      end
      
      class SHA256 < Base
        def type
          return "sha-256"
        end
      end

      class MD5 < Base
        def type
          return "md5"
        end
        
        def self.from_file(file)
          digest = Digest::MD5.new
          File.open(file.path, 'r') do |f|
            buff = ""
            while (f.read(1024, buff) != nil)
              digest << buff
            end
          end
          return Mrt::Ingest::MessageDigest::MD5.new(digest.hexdigest)
        end
      end

      class SHA1 < Base
        def type
          return "sha-1"
        end
      end
    end
  end
end

