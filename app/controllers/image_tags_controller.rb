class ImageTagsController < ApplicationController
  before_action :set_image
  before_action :set_tag

  def create
    unless @image.tags.include?(@tag)
      @image.tags << @tag
    end

    redirect_to @image
  end

  def destroy
    @image.tags.delete(@tag)

    redirect_to @image
  end

  private

  def set_image
    @image = Image.find(params[:image_id])
  end

  def set_tag
    @tag = Tag.find(params[:id])
  end
end
