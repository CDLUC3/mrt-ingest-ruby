# Author::    Erik Hetzner  (mailto:erik.hetzner@ucop.edu)
# Copyright:: Copyright (c) 2011, Regents of the University of California

require 'webrick'

# An HTTP server that will serve each file ONCE before shutting down.
module Mrt
  module Ingest
    class OneTimeServer
      # Find an open port, starting with start and adding one until we get
      # an open port
      def get_open_port(start = 8081)
        try_port = start
        loop do
          begin
            s = TCPServer.open(try_port)
            s.close
            return try_port
          rescue Errno::EADDRINUSE
            try_port += 1
          end
        end
      end

      def initialize
        @dir = Dir.mktmpdir
        @mutex = Mutex.new
        @known_paths = {}
        @requested = {}
        @port = get_open_port
        @file_callback = ->(req, _res) do
          @requested[req.path] ||= true
        end

        config = { Port: @port }
        @server = WEBrick::HTTPServer.new(config)
        @server.mount('/', WEBrick::HTTPServlet::FileHandler, @dir,
                      { FileCallback: @file_callback })
      end

      # Return true if each file has been served.
      def finished?
        Dir.entries(@dir).each do |entry|
          next if entry == '.' || entry == '..'
          return false if @requested["/#{entry}"].nil?
        end
        true
      end

      def get_temppath
        tmpfile = Tempfile.new('tmp', @dir)
        tmppath = tmpfile.path
        tmpfile.close!
        @mutex.synchronize do
          unless @known_paths.key?(tmppath)
            # no collision
            @known_paths[tmppath] = true
            return tmppath
          end
        end
        # need to retry, there was a collision
        get_temppath
      end

      # Add a file to this server. Returns the URL to use
      # to fetch the file & the file path
      def add_file(sourcefile = nil)
        fullpath = get_temppath
        path = File.basename(fullpath)
        if !sourcefile.nil?
          @server.mount("/#{path}",
                        WEBrick::HTTPServlet::FileHandler,
                        sourcefile.path,
                        { FileCallback: @file_callback })
        else
          File.open(fullpath, 'w+') do |f|
            yield f
          end
        end
        ["http://#{Socket.gethostname}:#{@port}/#{path}", fullpath]
      end

      def start_server
        if @thread.nil?
          @thread = Thread.new do
            @server.start
          end
        end
        sleep(0.1) while @server.status != :Running
        @thread
      end

      # Stop server unconditionally.
      def stop_server
        @server.shutdown
        @thread.join
      end

      # Wait for server to finish serving all files.
      def join_server
        # ensure that each file is requested once before shutting down
        until finished? do sleep(1) end
        @server.shutdown
        @thread.join
      end

      # Run the server and wait until each file has been served once.
      # Cleans up files before it returns.
      def run
        start_server
        join_server
        #    FileUtils.rm_rf(@dir)
        nil
      end
    end
  end
end
