# Author::    Erik Hetzner  (mailto:erik.hetzner@ucop.edu)
# Copyright:: Copyright (c) 2011, Regents of the University of California

require 'webrick'

# An HTTP server that will serve each file ONCE before shutting down.
module Mrt
  module Ingest
    class OneTimeServer
      # Find an open port, starting with start and adding one until we get
      # an open port
      def get_open_port(start=8080)
        try_port = start
        while (true)
          begin
            s = TCPServer.open(try_port)
            s.close
            return try_port
          rescue Errno::EADDRINUSE
            try_port = try_port + 1
          end
        end
      end

      def initialize
        @dir = Dir.mktmpdir
        @mutex = Mutex.new
        @known_paths = {}
        @requested = {}
        @port = get_open_port()
        @file_callback = lambda do |req, res|
          @requested[req.path] ||= true
        end
      
        config = { :Port => @port }
        @server = WEBrick::HTTPServer.new(config)
        @server.mount("/", WEBrick::HTTPServlet::FileHandler, @dir,
                      { :FileCallback=>@file_callback })
      end

      # Return true if each file has been served.
      def finished?
        Dir.entries(@dir).each do |entry|
          next if (entry == "." || entry == "..")
          if @requested["/#{entry}"].nil? then
            return false
          end
        end
        return true
      end

      def get_temppath
        tmpfile = Tempfile.new("tmp", @dir)
        tmppath = tmpfile.path
        tmpfile.close!
        @mutex.synchronize do
          if !@known_paths.has_key?(tmppath) then
            # no collision
            @known_paths[tmppath] = true
            return tmppath
          end
        end
        # need to retry, there was a collision
        return get_temppath
      end

      # Add a file to this server. Returns the URL to use to fetch the
      # file.
      def add_file(sourcefile=nil)
        fullpath = get_temppath()
        path = File.basename(fullpath)
        if !sourcefile.nil? then
          @server.mount("/#{path}",
                        WEBrick::HTTPServlet::FileHandler,
                        sourcefile.path,
                        { :FileCallback=>@file_callback })
        else
          File.open(fullpath, 'w+') do |f|
            yield f
          end
        end
        return "http://#{Socket.gethostname}:#{@port}/#{path}"
      end
      
      def start_server
        @thread = Thread.new do
          @server.start
        end
        return @thread
      end

      # Stop server unconditionally.
      def stop_server
        @server.shutdown
        @thread.join
      end

      # Wait for server to finish serving all files.
      def join_server
        # ensure that each file is requested once before shutting down
        while (!self.finished?) do sleep(1) end
        @server.shutdown 
        @thread.join
      end
      
      # Run the server and wait until each file has been served once.
      # Cleans up files before it returns.
      def run
        start_server()
        join_server()
        #    FileUtils.rm_rf(@dir)
        return
      end
    end
  end
end
