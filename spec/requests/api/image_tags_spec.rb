require 'rails_helper'

describe "Api::ImageTagsController", type: :request do
  let(:image) { create(:image, tags: [tag_a]) }
  let(:tag_a) { create(:tag, name: 'tag_a', alt_name: nil) }
  let(:tag_b) { create(:tag, name: 'tag_b', alt_name: nil) }

  describe "GET /api/images/:id/tags" do
    it "returns tags" do
      get api_image_image_tags_path(image, format: :json)

      expect(response).to have_http_status(200)
      expect(response.body).to be_json([
        {id: tag_a.id, name: 'tag_a', alt_name: nil, _links: Hash},
      ])
    end
  end

  describe "POST /api/images/:id/tags" do
    it "adds tag" do
      post api_image_image_tags_path(image, format: :json), id: tag_b.id

      expect(response).to have_http_status(201)
      expect(image.tags.reload).to eq([tag_a, tag_b])
    end

    it "adds tag only once" do
      image.tags << tag_b

      post api_image_image_tags_path(image, format: :json), id: tag_b.id
      expect(response).to have_http_status(201)

      expect(image.tags.reload).to eq([tag_a, tag_b])
    end
  end

  describe "DELETE /api/images/:id/tags" do
    it "removes tag" do
      delete api_image_image_tag_path(image, tag_a, format: :json)

      expect(response).to have_http_status(204)
      expect(image.tags.reload).to eq([])
    end
  end
end
