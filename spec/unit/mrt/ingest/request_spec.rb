require 'spec_helper'

module Mrt::Ingest
  describe Request do
    describe :new do
      it 'should require a profile' do
        expect do
          Mrt::Ingest::Request.new(profile: nil, submitter: 'jd/John Doe', type: 'file')
        end.to raise_error(ArgumentError)
      end

      it 'should require a submitter' do
        expect do
          Mrt::Ingest::Request.new(profile: 'demo_merritt', submitter: nil, type: 'file')
        end.to raise_error(ArgumentError)
      end

      it 'should require a type' do
        expect do
          Mrt::Ingest::Request.new(profile: 'demo_merritt', submitter: 'jd/John Doe', type: nil)
        end.to raise_error(ArgumentError)
      end
    end
  end
end
