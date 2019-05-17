require 'spec_helper'

module Mrt::Ingest
  module MessageDigest
    describe SHA256 do
      it 'wraps an SHA256 digest' do
        value = '40191d95b873db0b6ac09aca3cf51188ce914920a2330ddda1d88f75d93588e6'
        digest = SHA256.new(value)
        expect(digest.value).to eq(value)
        expect(digest.type).to eq('sha-256')
      end
    end
    describe MD5 do
      it 'wraps an MD5 digest' do
        value = 'b6d8a343fe281e92f1296283c29efc72'
        digest = MD5.new(value)
        expect(digest.value).to eq(value)
        expect(digest.type).to eq('md5')
      end

      describe :from_file do
        it 'hashes a file in text mode' do
          digest = MD5.from_file(File.new('spec/unit/data/file.txt'))
          expect(digest.value).to eq('91b767c2da0e8bfe318aee57d907d5f7')
          expect(digest.type).to eq('md5')
        end
      end
    end
    describe SHA1 do
      it 'wraps an SHA1 digest' do
        value = '08eefa1ab77c34a479310632923771f835c475e3'
        digest = SHA1.new(value)
        expect(digest.value).to eq(value)
        expect(digest.type).to eq('sha1')
      end
    end
  end
end
