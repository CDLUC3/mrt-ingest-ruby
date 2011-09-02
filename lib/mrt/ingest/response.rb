require 'rubygems'

require 'json'
require 'time'

module Mrt
  module Ingest
    class Response
      def initialize(data)
        @parsed = JSON.parse(data)['batchState']
      end
      
      def batch_id
        return @parsed['batchID']
      end
      
      def user_agent
        return @parsed['userAgent']
      end
      
      def submission_date
        return Time.parse(@parsed['submissionDate'])
      end
    end
  end
end
