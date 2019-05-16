require 'spec_helper'

module Mrt::Ingest
  describe Client do
    describe :new do
      it 'creates a client' do
        client = Client.new('http://example.org/ingest')
        expect(client).to be_a(Client)
      end

      it 'accepts credentials' do
        client = Client.new('http://example.org/ingest', 'me', 'secret')
        expect(client).to be_a(Client)
      end
    end

    describe :mk_request do
      before(:each) do
        @client = Client.new('http://example.org/ingest', 'me', 'secret')
        @iobject = IObject.new
        @ingest_req = @iobject.mk_request('profile', 'submitter')
      end

      it 'creates a valid request' do
        rest_req = @client.mk_rest_request(@ingest_req)
        expect(rest_req.user).to eq('me')
        expect(rest_req.password).to eq('secret')
      end
    end
  end
end
