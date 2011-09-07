# Author::    Erik Hetzner  (mailto:erik.hetzner@ucop.edu)
# Copyright:: Copyright (c) 2011, Regents of the University of California

module Mrt
  module Ingest
    class RequestException < Exception
    end

    # Represents a request to be sent to an ingest server.
    class Request
      attr_accessor :creator, :date, :local_identifier,
                    :primary_identifier, :profile, :note, :submitter,
                    :title, :type

      # Options is a hash; required are :profile, :submitter, :type.
      # May also include :creator, :date, :digest, :file, :filename,
      # :local_identifier, :primary_identifier, :note, :title.
      def initialize(options)
        @creator = options[:creator]
        @date = options[:date]
        @digest = options[:digest]
        @file = options[:file]
        @filename = options[:filename]
        @local_identifier = options[:local_identifier]
        @primary_identifier = options[:primary_identifier]
        @profile = options[:profile]
        @note = options[:note]
        @submitter = options[:submitter]
        @title = options[:title]
        @type = options[:type]
        [:profile, :submitter, :type].each do |arg|
          raise RequestException.new("#{arg} is required.") if options[arg].nil?
        end
      end
      
      # Returns a hash of arguments suitable for sending to a server.
      def mk_args
        return {
          'creator'           => @creator,
          'date'              => @date,
          'digestType'        => ((!@digest.nil? && @digest.type) || nil),
          'digestValue'       => ((!@digest.nil? && @digest.value) || nil),
          'file'              => @file,
          'filename'          => @filename,
          'localIdentifier'   => @local_identifier,
          'primaryIdentifier' => @primary_identifier,
          'profile'           => @profile,
          'note'              => @note,
          'responseForm'      => 'json',
          'submitter'         => @submitter,
          'title'             => @title,
          'type'              => @type
        }.reject{|k, v| v.nil? || (v == '')}
      end
    end
  end
end
