require 'spec_helper'

module Mrt::Ingest
  describe Component do
    describe :from_erc do
      it 'rejects string ERCs' do
        server = instance_double(OneTimeServer)
        expect { Component.from_erc(server, 'I am not an ERC') }.to raise_error(ArgumentError)
      end
    end
  end
end
