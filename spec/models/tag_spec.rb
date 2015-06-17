require 'rails_helper'

RSpec.describe Tag, type: :model do
  it "sets root's tag id to parent_id when parent_id given" do
    tag_a = create(:tag, name: 'THE IDOLM@STER')
    tag_b = create(:tag, name: 'THE IDOLM@STER CINDERELLA GIRLS', parent: tag_a)
    tag_c = create(:tag, name: 'new generations', parent: tag_b)

    expect(tag_c.parent_id).to eq tag_a.id
  end

end
