require 'rails_helper'

RSpec.describe Image, type: :model do
  describe "#image_url" do
    subject { image.image_url }

    context do
      let(:image) { build(:image) }

      it { is_expected.to eq image.source_url }
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
