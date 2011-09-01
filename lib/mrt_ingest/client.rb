require 'rubygems'

require 'rest-client'

module Mrt
  module Ingest

    class Client
      def initialize(base_uri)
        @base_uri = base_uri
      end
      
      def ingest(request)
        return Response.new(RestClient.post(@base_uri, request.mk_args(), { :multipart => true }))
      end
    end
  end
end
