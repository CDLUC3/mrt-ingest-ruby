require 'mrt_ingest'
require 'uri'

module Mrt
  module Ingest
    # An object ready for ingest into Merritt.
    class IObject
      def initialize(options={})
        @primary_identifier = options[:primary_identifier]
        @local_identifier = options[:local_identifier]
        @erc = options[:erc] || Hash.new
        @file_components = []
        @uri_components = []
        @server = Mrt::Ingest::OneTimeServer.new
      end
      
      def add_component(component, name)
        case component
          #when File
          #  @file_components.push(component)
        when URI
          @uri_components.push([component, name])
        else
          raise IngestException.new("Trying to add a component that is not a File or URI")
        end
      end
      
      # Make a Mrt::Ingest::Request object for this mrt-object
      def mk_request(profile, submitter)
        erc_url = @server.add_file do |f|
          @erc.each do |k, v|
            f.write("#{k}: #{v}\n")
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

      # Starts the web server for this object in a new thread. Returns
      # the thread.
      def start_server
        Thread.new do
          @server.run
        end
      end
        
      def mk_manifest(manifest, erc_url)
        manifest.write("#%checkm_0.7\n")
        manifest.write("#%profile http://uc3.cdlib.org/registry/ingest/manifest/mrt-ingest-manifest\n")
        manifest.write("#%prefix | mrt: | http://uc3.cdlib.org/ontology/mom#\n")
        manifest.write("#%prefix | nfo: | http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#\n")
        manifest.write("#%fields | nfo:fileUrl | nfo:hashAlgorithm | nfo:hashValue | nfo:fileSize | nfo:fileLastModified | nfo:fileName | mrt:mimeType\n")
        @uri_components.each { |uri|
          manifest.write("#{uri[0]} | | | | | #{url[1]} |\n")
        }
        manifest.write("#{erc_url} | | | | | mrt-erc.txt\n")
        manifest.write("#%EOF\n")
      end
    end
  end
end
