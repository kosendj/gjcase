require 'rails_helper'

RSpec.describe Tag, type: :model do
  it "sets root's tag id to parent_id when parent_id given" do
    tag_a = create(:tag, name: 'THE IDOLM@STER')
    tag_b = create(:tag, name: 'THE IDOLM@STER CINDERELLA GIRLS', parent: tag_a)
    tag_c = create(:tag, name: 'new generations', parent: tag_b)

    expect(tag_c.parent_id).to eq tag_a.id
  end

  describe "#search" do
    let!(:tag) { create(:tag, name: 'awesome') }

    context "when id given" do
      subject { described_class.search(tag.id.to_s) }
      it { is_expected.to eq tag }
    end

    context "when name given" do
      subject { described_class.search(tag.name) }
      it { is_expected.to eq tag }
    end

    context "when found tag has merged to other" do
      let!(:new_tag) { create(:tag, name: 'great') }

      before do
        tag.merge_to!(new_tag)
      end

      subject { described_class.search(tag.id) }

      it { is_expected.to eq new_tag }
    end

    context "when not found" do
      subject { described_class.search('xxxx') }
      it { is_expected.to be_nil }
    end
  end

  describe "#search!" do
    let!(:tag) { create(:tag, name: 'awesome') }

    context "when id given" do
      subject { described_class.search!(tag.id.to_s) }
      it { is_expected.to eq tag }
    end

    context "when name given" do
      subject { described_class.search!(tag.name) }
      it { is_expected.to eq tag }
    end

    context "when not found" do
      subject { described_class.search!('xxxx') }

      it "raises RecordNotFound" do
        expect {
          subject
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#merge_to!" do
    it "updates merged_to_id" do
      tag_a = create(:tag, name: 'tag_a')
      tag_b = create(:tag, name: 'tag_b')

      tag_b.merge_to!(tag_a)
      tag_b.reload

      expect(tag_b.merged_tag).to eq(tag_a)
    end

    it "updates its images to link to merged tag" do
      tag_a = create(:tag, name: 'tag_a')
      tag_b = create(:tag, name: 'tag_b')
      image = create(:image, tags: [tag_b])

      tag_b.merge_to!(tag_a)
      image.reload

      expect(image.tags).to eq([tag_a])
    end
  end
end
