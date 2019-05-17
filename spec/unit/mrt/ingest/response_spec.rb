require 'spec_helper'

module Mrt::Ingest
  describe Response do
    RESPONSE_JSON = <<~JSON.freeze
      {
          "bat:batchState": {
              "bat:batchID":"bid-8c0fa0c2-f3d7-4deb-bd49-f953f6752b59",
              "bat:updateFlag":false,
              "bat:targetQueue":"example.org:2181",
              "bat:batchStatus":"QUEUED",
              "bat:userAgent":"egh/Erik Hetzner",
              "bat:submissionDate":"2011-08-31T15:40:26-07:00",
              "bat:targetQueueNode":"/ingest.example.1",
              "bat:batchProfile": {
                  "bat:owner":"ark:/99999/fk4tt4wsh",
                  "bat:creationDate":"2010-01-19T13:28:14-08:00",
                  "bat:targetStorage": {
                      "bat:storageLink":"http://example.org:35121",
                      "bat:nodeID":10
                  },
                  "bat:objectType":"MRT-curatorial",
                  "bat:modificationDate":"2010-01-26T23:28:14-08:00",
                  "bat:aggregateType":"",
                  "bat:objectMinterURL":"https://example.org/ezid/shoulder/ark:/99999/fk4",
                  "bat:collection": {
                  },
                  "bat:profileID":"merritt_content",
                  "bat:profileDescription":"Merritt demo content",
                  "bat:fixityURL":"http://example.org:33143",
                  "bat:contactsEmail": {
                      "bat:notification": {
                          "bat:contactEmail":"erik.hetzner@example.org"
                      }
                  },
                  "bat:identifierScheme":"ARK",
                  "bat:identifierNamespace":"99999",
                  "bat:objectRole":"MRT-content"
              }
          }
      }
    JSON

    describe :new do
      before(:each) do
        @response = Response.new(RESPONSE_JSON)
      end

      it 'should parse the response' do
        expect(@response.batch_id).to eq('bid-8c0fa0c2-f3d7-4deb-bd49-f953f6752b59')
        expect(@response.submission_date).to eq(Time.at(1_314_830_426))
        expect(@response.user_agent).to eq('egh/Erik Hetzner')
      end
    end
  end
end
