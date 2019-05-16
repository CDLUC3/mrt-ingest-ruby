# Author::    Erik Hetzner  (mailto:erik.hetzner@ucop.edu)
# Copyright:: Copyright (c) 2011, Regents of the University of California

require 'rubygems'

require 'json'
require 'time'

module Mrt
  module Ingest
    class Response
      def initialize(data)
        @parsed = JSON.parse(data)['bat:batchState']
      end

      def batch_id
        @parsed['bat:batchID']
      end

      def user_agent
        @parsed['bat:userAgent']
      end

      def submission_date
        Time.parse(@parsed['bat:submissionDate'])
      end
    end
  end
end
