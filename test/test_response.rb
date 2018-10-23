# Author::    Erik Hetzner  (mailto:erik.hetzner@ucop.edu)
# Copyright:: Copyright (c) 2011, Regents of the University of California

require 'rubygems'

require 'test/unit'
require 'fakeweb'
require 'mocha'
require 'mrt/ingest'
require 'shoulda'

class TestResponse < Test::Unit::TestCase
  RESPONSE_JSON = <<EOS
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
EOS

  context "when creating a response" do
    setup do
      @response = Mrt::Ingest::Response.new(RESPONSE_JSON)
    end
    
    should "have the right properties" do
      assert_equal("bid-8c0fa0c2-f3d7-4deb-bd49-f953f6752b59", @response.batch_id)
      assert_equal(Time.at(1314830426), @response.submission_date)
    end
  end
end
