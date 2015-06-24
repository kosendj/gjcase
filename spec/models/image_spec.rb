require 'rails_helper'

RSpec.describe Image, type: :model do
  describe "#image_url" do
    subject { image.image_url }
    let(:image) { build(:image) }

    context do
      it { is_expected.to eq image.source_url }
    end

    context "with storage_path" do
      before do
        image.source_url = 'http://source-test.kosendj-bu.in/source.gif'
        image.storage_path = 'test/test.gif'
      end

      it { is_expected.to eq image.source_url }

      context "when storage_url is set" do
        before do
          allow(Rails.application.secrets).to receive(:storage_url).and_return('http://sto-test.kosendj-bu.in')
        end

        it { is_expected.to eq "http://sto-test.kosendj-bu.in/test/test.gif" }

        context "when camo is set" do
          before do
            allow_any_instance_of(Camo).to receive(:url).with("http://sto-test.kosendj-bu.in/test/test.gif").and_return('http://camo-test.kosendj-bu.in/camo.gif')

            allow(Rails.application.secrets).to receive(:camo).and_return('http://camo-test.kosendj-bu.in')
            allow(Rails.application.secrets).to receive(:camo_key).and_return('deadbeef')
          end

          it { is_expected.to eq 'http://camo-test.kosendj-bu.in/camo.gif' }
        end
      end

      context "when camo is set" do
        before do
          allow_any_instance_of(Camo).to receive(:url).with(image.source_url).and_return('http://camo-test.kosendj-bu.in/camo.gif')

          allow(Rails.application.secrets).to receive(:camo).and_return('http://camo-test.kosendj-bu.in')
          allow(Rails.application.secrets).to receive(:camo_key).and_return('deadbeef')
        end

        it { is_expected.to eq 'http://camo-test.kosendj-bu.in/camo.gif' }
      end
    end
  end

  describe "validation" do
    let(:image) { create(:image) }
    it "prevents source_url from update" do
      expect(image).to be_valid
      image.source_url = 'xxx'
      expect(image).not_to be_valid
    end
  end
end
