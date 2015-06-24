require 'spec_helper'
require_relative '../../lib/autoload/camo'


describe Camo do
  let(:camo) {
    Camo.new('http://example-camo.kosendj-bu.in', 'deadbeef')
  }

  describe "#url" do
    subject { camo.url('http://example.kosendj-bu.in/x.gif') }

    it { is_expected.to eq 'http://example-camo.kosendj-bu.in/48d2c396384c451c9b21cf5261bac2896a7e1097/687474703a2f2f6578616d706c652e6b6f73656e646a2d62752e696e2f782e676966' }
  end
end

