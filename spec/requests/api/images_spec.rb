require 'rails_helper'

RSpec.describe "Api::ImagesController", type: :request do
  describe "GET /api/images" do
    let(:tag) { create(:tag, name: 'tag', alt_name: nil) }

    before do
      @image_a = create(:image, comment: 'a', tags: [tag])
      @image_b = create(:image, comment: 'b')
    end

    context "with no param" do
      it "returns images" do
        get api_images_path(format: :json)
        expect(response).to have_http_status(200)
        expect(response.body).to be_json([
          {id: @image_a.id, image_url: @image_a.image_url, comment: 'a'},
          {id: @image_b.id, image_url: @image_b.image_url, comment: 'b'},
        ])
      end
    end

    context "with fields=__default__,tags" do
      it "returns images" do
        get api_images_path(format: :json, fields: '__default__,tags')
        expect(response).to have_http_status(200)
        expect(response.body).to be_json([
          {id: @image_a.id, image_url: @image_a.image_url, comment: 'a', tags: [id: Integer, alt_name: nil, name: 'tag', _links: Hash]},
          {id: @image_b.id, image_url: @image_b.image_url, comment: 'b', tags: []},
        ])
      end
    end

    context "with tags=tag" do
      it "returns images" do
        get api_images_path(format: :json, tags: 'tag')
        expect(response).to have_http_status(200)
        expect(response.body).to be_json([
          {id: @image_a.id, image_url: @image_a.image_url, comment: 'a'},
        ])
      end
    end

    context "with tags={id}" do
      it "returns images" do
        get api_images_path(format: :json, tags: tag.id)
        expect(response).to have_http_status(200)
        expect(response.body).to be_json([
          {id: @image_a.id, image_url: @image_a.image_url, comment: 'a'},
        ])
      end
    end
  end
end
