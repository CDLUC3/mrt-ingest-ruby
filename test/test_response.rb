require 'rubygems'

require 'fakeweb'
require 'mocha'
require 'mrt/ingest'
require 'shoulda'

class TestResponse < Test::Unit::TestCase
  RESPONSE_JSON = <<EOS
{

    "batchState": {
        "batchID":"bid-8c0fa0c2-f3d7-4deb-bd49-f953f6752b59",
        "updateFlag":false,
        "targetQueue":"example.org:2181",
        "batchStatus":"QUEUED",
        "userAgent":"egh/Erik Hetzner",
        "submissionDate":"2011-08-31T15:40:26-07:00",
        "targetQueueNode":"/ingest.example.1",
        "batchProfile": {
            "owner":"ark:/99999/fk4tt4wsh",
            "creationDate":"2010-01-19T13:28:14-08:00",
            "targetStorage": {
                "storageLink":"http://example.org:35121",
                "nodeID":10
            },
            "objectType":"MRT-curatorial",
            "modificationDate":"2010-01-26T23:28:14-08:00",
            "aggregateType":"",
            "objectMinterURL":"https://example.org/ezid/shoulder/ark:/99999/fk4",
            "collection": {
            },
            "profileID":"merritt_content",
            "profileDescription":"Merritt demo content",
            "fixityURL":"http://example.org:33143",
            "contactsEmail": {
                "notification": {
                    "contactEmail":"erik.hetzner@example.org"
                }
            },
            "identifierScheme":"ARK",
            "identifierNamespace":"99999",
            "objectRole":"MRT-content"
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
