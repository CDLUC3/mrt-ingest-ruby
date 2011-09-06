# Author::    Erik Hetzner  (mailto:erik.hetzner@ucop.edu)
# Copyright:: Copyright (c) 2011, Regents of the University of California

require 'rubygems'

require 'rest-client'

module Mrt
  module Ingest

    class Client
      def initialize(base_uri, username=nil, password=nil)
        @base_uri = base_uri
        @username = username
        @password = password
      end
      
      def mk_rest_request(ingest_req)
        args = { 
          :method   => :post,
          :url      => @base_uri,
          :user     => @username,
          :password => @password,
          :payload  => ingest_req.mk_args(),
          :headers  => { :multipart => true } }.delete_if { |k,v| (v.nil? || v == "") }
        return RestClient::Request.new(args)
      end

      def ingest(ingest_req)
        return Response.new(mk_rest_request(ingest_req).execute())
      end
    end
  end
end
