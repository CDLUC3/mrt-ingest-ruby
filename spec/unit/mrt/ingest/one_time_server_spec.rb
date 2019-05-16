require 'spec_helper'
require 'English'

module Mrt::Ingest
  describe OneTimeServer do
    attr_reader :server

    before(:each) do
      @server = OneTimeServer.new
      server.start_server
    end

    after(:each) do
      server.stop_server
    end

    describe :finished? do
      it 'returns true when all files have been served, false otherwise' do
        urls = (0..3).map do |i|
          url_str, = server.add_file { |f| f.puts("I am file #{i}") }
          url_str
        end

        urls.each do |url|
          expect(server.finished?).to be_falsey
          Net::HTTP.get(URI.parse(url))
        end

        expect(server.finished?).to be_truthy
      end
    end

    describe :temppath do
      it 'avoids collisions' do
        tmpfiles = []
        allow(Tempfile).to receive(:new).and_wrap_original do |m, *args|
          tmpfile = m.call(*args)
          if tmpfiles.empty?
            known_paths = server.instance_variable_get(:@known_paths)
            known_paths[tmpfile.path] = true
          end
          tmpfiles << tmpfile.path
          tmpfile
        end

        temppath = server.temppath
        expect(tmpfiles.size).to eq(2)
        expect(temppath).to eq(tmpfiles[1])
      end
    end

    describe :join_server do
      it 'blocks till all files have been served' do
        urls = (0..3).map do |i|
          url_str, = server.add_file { |f| f.puts("I am file #{i}") }
          url_str
        end

        joining_thread = Thread.new { server.join_server }
        expect(joining_thread.status).not_to be_falsey

        client_process_id = fork do
          begin
            urls.each do |url|
              resp = Net::HTTP.get_response(URI.parse(url))
              status = resp.code.to_i
              exit(status) if status != 200
            end
          rescue StandardError => e
            warn(e)
            exit(1)
          end
        end
        Process.wait(client_process_id)
        expect($CHILD_STATUS.exitstatus).to eq(0) # just to be sure

        Timeout.timeout(5) { joining_thread.join }
        expect(joining_thread.status).to eq(false)
      end
    end

    describe :run do
      it 'starts, serves, and stops' do
        server2 = OneTimeServer.new
        urls = (0..3).map do |i|
          url_str, = server2.add_file { |f| f.puts("I am file #{i}") }
          url_str
        end

        running_thread = Thread.new { server2.run }
        expect(running_thread.status).not_to be_falsey

        client_process_id = fork do
          begin
            urls.each do |url|
              resp = Net::HTTP.get_response(URI.parse(url))
              status = resp.code.to_i
              exit(status) if status != 200
            end
          rescue StandardError => e
            warn(e)
            exit(1)
          end
        end
        Process.wait(client_process_id)
        expect($CHILD_STATUS.exitstatus).to eq(0) # just to be sure

        Timeout.timeout(5) { running_thread.join }
        expect(running_thread.status).to eq(false)
      end
    end
  end
end
