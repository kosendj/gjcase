require 'rails_helper'

RSpec.describe "Api::TagsController", type: :request do
  describe "GET /api/tags" do
    let(:tag) { create(:tag, name: 'tag', alt_name: nil) }

    before do
      @tag_a = create(:tag, name: 'a', alt_name: nil)
      @tag_b = create(:tag, name: 'b', alt_name: nil)
    end

    context "with no param" do
      it "returns tags" do
        get api_tags_path(format: :json)
        expect(response).to have_http_status(200)
        expect(response.body).to be_json([
          {id: @tag_a.id, name: 'a', alt_name: nil, _links: Hash},
          {id: @tag_b.id, name: 'b', alt_name: nil, _links: Hash},
        ])
      end
    end
  end

  describe "POST /api/tags" do
    it "creates tag" do
      post api_tags_path(format: :json), name: 'new'
      expect(response).to have_http_status(201)

      tag = Tag.last
      expect(tag.name).to eq 'new'
    end
  end

  describe "PUT /api/tags/:id" do
    let(:tag) { create(:tag, name: 'foo') }

    it "updates tag" do
      put api_tag_path(tag, format: :json), name: 'bar'
      expect(response).to have_http_status(204)

      expect(tag.reload.name).to eq 'bar'
    end
  end
end
