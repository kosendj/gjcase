json.array!(@images) do |image|
  json.extract! image, :id, :source_url, :comment, :duplication_id, :tags, :image_url
  json.tags do
    json.array!(image.tags) do |tag|
      json.extract! tag, :name, :id, :parent_id
    end
  end
  json.url image_url(image, format: :json)
end
