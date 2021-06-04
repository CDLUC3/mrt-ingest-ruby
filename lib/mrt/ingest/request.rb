# Author::    Erik Hetzner  (mailto:erik.hetzner@ucop.edu)
# Copyright:: Copyright (c) 2011, Regents of the University of California

module Mrt
  module Ingest
    class RequestException < RuntimeError
    end

    # Represents a request to be sent to an ingest server.
    class Request

      attr_accessor :creator
      attr_accessor :date
      attr_accessor :digest
      attr_accessor :file
      attr_accessor :filename
      attr_accessor :local_identifier
      attr_accessor :note
      attr_accessor :primary_identifier
      attr_accessor :profile
      attr_accessor :submitter
      attr_accessor :title
      attr_accessor :type

      def initialize(
        profile:, submitter:, type:,
        creator: nil, date: nil, digest: nil, file: nil, filename: nil,
        local_identifier: nil, primary_identifier: nil, note: nil, title: nil
      )
        raise ArgumentError, 'profile cannot be nil' unless profile
        raise ArgumentError, 'profile cannot be submitter' unless submitter
        raise ArgumentError, 'profile cannot be type' unless type

        @creator = creator
        @date = date
        @digest = digest
        @file = file
        @filename = filename
        @local_identifier = local_identifier
        @primary_identifier = primary_identifier
        @profile = profile
        @note = note
        @submitter = submitter
        @title = title
        @type = type
      end

      # Returns a hash of arguments suitable for sending to a server.
      def mk_args
        {
          'creator' => creator,
          'date' => date,
          'digestType' => digest_type,
          'digestValue' => digest_value,
          'file' => file,
          'filename' => filename,
          'localIdentifier' => local_identifier,
          'primaryIdentifier' => primary_identifier,
          'profile' => profile,
          'note' => note,
          'responseForm' => 'json',
          'submitter' => submitter,
          'title' => title,
          'type' => type
        }.reject { |_k, v| v.nil? || (v == '') }
      end

      private

      def digest_value
        digest && digest.value
      end

      def digest_type
        digest && digest.type
      end
    end
  end
end
