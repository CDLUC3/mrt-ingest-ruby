module Mrt
  module Ingest
    module MessageDigest
      class Base
        attr_reader :value
        def init(value)
          @value = value
        end
      end
      
      class SHA256
        def type
          return "sha-256"
        end
      end

      class MD5
        def type
          return "md5"
        end
      end

      class SHA1
        def type
          return "sha-1"
        end
      end
    end
  end
end

