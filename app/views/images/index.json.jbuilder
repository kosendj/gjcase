json.array!(@images) do |image|
  json.extract! image, :id, :source_url, :comment, :storage_path, :sha, :duplication_id
  json.url image_url(image, format: :json)
end
