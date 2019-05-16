# Author::    Erik Hetzner  (mailto:erik.hetzner@ucop.edu)
# Copyright:: Copyright (c) 2011, Regents of the University of California

module Mrt
  module Ingest
    autoload :Client, 'mrt/ingest/client'
    autoload :IObject, 'mrt/ingest/iobject'
    autoload :MessageDigest, 'mrt/ingest/message_digest'
    autoload :OneTimeServer, 'mrt/ingest/one_time_server'
    autoload :Request, 'mrt/ingest/request'
    autoload :Response, 'mrt/ingest/response'

    class IngestException < RuntimeError
    end
  end
end
