class Api::ImageTagsController < Api::BaseController
  self.resource_class = Tag

  prepend_before_action :require_image
  prepend_before_action :require_tag, only: %i(create destroy)

  def require_resources
    @resources = @image.tags
  end

  def require_resource
    @resource = @image.tags.find_by_id!(params[:id])
  end

  def destroy_resource
    @image.tags.delete(@tag)
    @resource = @tag
  end

  def create_resource
    @image.tags << @tag unless @image.tags.include?(@tag)
    @resource = @tag
  end

  def respond_with_resources_options
    {paginate: true}
  end

  private def require_tag
    @tag = Tag.search!(params[:id])
  end

  private def require_image
    @image = Image.find(params[:image_id])
  end
end

