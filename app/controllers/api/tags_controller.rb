class Api::TagsController < Api::BaseController
  def require_resources
    if params[:include_merged]
      @resources = Tag.all
    else
      @resources = Tag.active
    end
  end

  def require_resource
    @resource = Tag.find(params[:id])
  end

  def create_resource
    @resource = Tag.create!(tag_params)
  end

  def update_resource
    @resource.update_attributes!(tag_params)
    @resource
  end

  def respond_with_resources_options
    {paginate: true}
  end

  private def tag_params
    params.permit(:name, :alt_name)
  end
end
