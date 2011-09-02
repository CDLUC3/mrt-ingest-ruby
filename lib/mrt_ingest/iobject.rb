require 'mrt_ingest'
require 'tempfile'
require 'uri'

module Mrt
  module Ingest
    # An object ready for ingest into Merritt.
    class IObject
      
      attr_accessor :primary_identifier, :local_identifier, :erc, :erc_file

      def initialize(options={})
        @primary_identifier = options[:primary_identifier]
        @local_identifier = options[:local_identifier]
        @erc = options[:erc] || Hash.new
        @components = []
        @server = options[:server] || Mrt::Ingest::OneTimeServer.new
      end
      
      def add_component(component, name=nil)
        case component
        when File, Tempfile
          name = File.basename(component.path) if name.nil?
          @components.push([@server.add_file(component), name])
        when URI
          name = File.basename(component.to_s) if name.nil?
          @components.push([component, name])
        else
          raise IngestException.new("Trying to add a component that is not a File or URI")
        end
      end
      
      # Make a Mrt::Ingest::Request object for this mrt-object
      def mk_request(profile, submitter)
        erc_url = case @erc
                  when URI
                    @erc
                  when File, Tempfile
                    @server.add_file(@erc)
                  when Hash
                    @server.add_file do |f|
                      @erc.each do |k, v|
                        f.write("#{k}: #{v}\n")
                      end
                    end
                  end
        manifest_file = Tempfile.new("mrt-ingest")
        mk_manifest(manifest_file, erc_url)
        # reset to beginning
        manifest_file.open
        return Mrt::Ingest::Request.
          new(:file               => manifest_file,
              :filename           => manifest_file.path.split(/\//).last,
              :type               => "object-manifest",
              :submitter          => submitter,
              :profile            => profile,
              :primary_identifier => @primary_identifier)
      end

      def start_server
        return @server.start_server()
      end

      def join_server
        return @server.join_server()
      end

      def stop_server
        return @server.stop_server()
      end
        
      def mk_manifest(manifest, erc_url)
        manifest.write("#%checkm_0.7\n")
        manifest.write("#%profile http://uc3.cdlib.org/registry/ingest/manifest/mrt-ingest-manifest\n")
        manifest.write("#%prefix | mrt: | http://uc3.cdlib.org/ontology/mom#\n")
        manifest.write("#%prefix | nfo: | http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#\n")
        manifest.write("#%fields | nfo:fileUrl | nfo:hashAlgorithm | nfo:hashValue | nfo:fileSize | nfo:fileLastModified | nfo:fileName | mrt:mimeType\n")
        @components.each { |c|
          manifest.write("#{c[0]} | | | | | #{c[1]} | \n")
        }
        manifest.write("#{erc_url} | | | | | mrt-erc.txt | \n")
        manifest.write("#%EOF\n")
      end
      
      def start_ingest(client, profile, submitter)
        request = mk_request(profile, submitter)
        start_server
        @response = client.ingest(request)
        return @response
      end

      def finish_ingest
        join_server
      end
    end
  end
end
