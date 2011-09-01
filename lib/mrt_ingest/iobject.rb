require 'mrt_ingest'
require 'uri'

module Mrt
  module Ingest
    # An object ready for ingest into Merritt.
    class IObject
      def initialize(erc={})
        @erc = erc
        @file_components = []
        @uri_components = []
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
      
      # Make a Mrt::Ingest::Request object for this
      def mk_request
        manifest_file = Tempfile.new("mrt-ingest")
        mk_manifest(manifest_file, urls)
        # reset to beginning
        manifest_file.open        
      end
      
      private
      def mk_manifest(manifest)
        manifest.write("#%checkm_0.7\n")
        manifest.write("#%profile http://uc3.cdlib.org/registry/ingest/manifest/mrt-ingest-manifest\n")
        manifest.write("#%prefix | mrt: | http://uc3.cdlib.org/ontology/mom#\n")
        manifest.write("#%prefix | nfo: | http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#\n")
        manifest.write("#%fields | nfo:fileUrl | nfo:hashAlgorithm | nfo:hashValue | nfo:fileSize | nfo:fileLastModified | nfo:fileName | mrt:mimeType\n")
        @uri_components.each { |uri|
          manifest.write("#{uri[0]} | | | | | #{url[1]} |\n")
        }
        manifest.write("#%EOF\n")
      end
    end
  end
end

