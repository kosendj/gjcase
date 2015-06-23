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
          {id: @image_a.id, image_url: @image_a.image_url, comment: 'a', _links: Hash},
          {id: @image_b.id, image_url: @image_b.image_url, comment: 'b', _links: Hash},
        ])
      end
    end

    context "with fields=__default__,tags" do
      it "returns images" do
        get api_images_path(format: :json, fields: '__default__,tags')
        expect(response).to have_http_status(200)
        expect(response.body).to be_json([
          {id: @image_a.id, image_url: @image_a.image_url, comment: 'a', _links: Hash, tags: [id: Integer, alt_name: nil, name: 'tag', _links: Hash]},
          {id: @image_b.id, image_url: @image_b.image_url, comment: 'b', _links: Hash, tags: []},
        ])
      end
    end

    context "with tags=tag" do
      it "returns images" do
        get api_images_path(format: :json, tags: 'tag')
        expect(response).to have_http_status(200)
        expect(response.body).to be_json([
          {id: @image_a.id, image_url: @image_a.image_url, comment: 'a', _links: Hash},
        ])
      end
    end

    context "with tags={id}" do
      it "returns images" do
        get api_images_path(format: :json, tags: tag.id)
        expect(response).to have_http_status(200)
        expect(response.body).to be_json([
          {id: @image_a.id, image_url: @image_a.image_url, comment: 'a', _links: Hash},
        ])
      end
    end
  end

  describe "POST /api/images" do
    it "creates image" do
      post api_images_path(format: :json), source_url: 'http://localhost:3000/test_source/foo.gif', comment: 'beautiful'
      expect(response).to have_http_status(201)

      image = Image.last
      expect(image.source_url).to eq 'http://localhost:3000/test_source/foo.gif'
      expect(image.comment).to eq 'beautiful'
    end
  end

  describe "PUT /api/images/:id" do
    let(:image) { create(:image, comment: 'foo') }

    it "updates image" do
      put api_image_path(image, format: :json), comment: 'bar'
      expect(response).to have_http_status(204)

      expect(image.reload.comment).to eq 'bar'
    end
  end
end
