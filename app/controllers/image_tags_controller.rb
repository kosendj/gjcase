class ImageTagsController < ApplicationController
  before_action :set_image
  before_action :set_tag

  def create
    unless @image.tags.include?(@tag)
      @image.tags << @tag
    end

    respond_to do |format|
      format.html { redirect_to @image }
      format.json { render(json: {tag: @tag, image: @image}) }
    end
  end

  def destroy
    @image.tags.delete(@tag)

    respond_to do |format|
      format.html { redirect_to @image }
      format.json { render(json: {tag: @tag, image: @image}) }
    end
  end

  private

  def set_image
    @image = Image.find(params[:image_id])
  end

  def set_tag
    @tag = Tag.search!(params[:id])
  end
end
