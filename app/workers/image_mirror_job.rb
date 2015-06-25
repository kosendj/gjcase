class ImageMirrorJob
  include Sidekiq::Worker

  def perform(id)
    Image.find(id).mirror!
  end
end


