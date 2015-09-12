class Api::ImagesController < Api::BaseController
  def require_resources
    if params[:include_duplications]
      @resources = Image.all
    else
      @resources = Image.unduplicated
    end

    if params[:tags].present?
      # XXX:
      tag_queries = [*params[:tags]]
      tag_ids = Tag.where(id: tag_queries.grep(/\A[0-9]+\z/)).pluck(:id) \
              + Tag.where(name: tag_queries).pluck(:id)
      image_ids = TagAssignment.where(tag_id: tag_ids).pluck(:image_id)
      @resources = @resources.where(id: image_ids).page(params[:page])
    end

    @resources = @resources.order(id: :desc).includes(:tags)
  end

  def require_resource
    @resource = Image.find(params[:id])
  end

  def create_resource
    @resource = Image.create!(image_params)
  end

  def update_resource
    @resource.update_attributes! image_params
    @resource
  end

  def respond_with_resources_options
    {paginate: true}
  end

  private def image_params
    params.permit(:source_url, :comment)
  end
end
