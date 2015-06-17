require 'rails_helper'

RSpec.describe ImageTagsController, type: :controller do
  let!(:image) { create(:image) }
  let!(:tag) { create(:tag) }

  describe "POST #create" do
    it "creates tag assignment" do
      post :create, image_id: image.id, id: tag.id
      expect(response).to redirect_to(image)

      image.reload
      expect(image.tags).to eq [tag]
    end

    context "when it already exists" do
      before do
        image.tags << tag
      end

      it "does nothing" do
        post :create, image_id: image.id, id: tag.id
        expect(response).to redirect_to(image)

        image.reload
        expect(image.tags).to eq [tag]
      end
    end
  end

  describe "DELETE #destroy" do
    context "when tag assignment exists" do
      before do
        image.tags << tag
      end

      it "deletes tag assignment" do
        delete :destroy, image_id: image.id, id: tag.id
        expect(response).to redirect_to(image)

        image.reload
        expect(image.tags).to eq []
      end
    end

    context "when tag assignment doesn't exist" do
      it "does nothing" do
        delete :destroy, image_id: image.id, id: tag.id
        expect(response).to redirect_to(image)

        image.reload
        expect(image.tags).to eq []
      end
    end
  end

end
