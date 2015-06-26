class Image < ActiveRecord::Base
  include Garage::Representer

  validates :source_url, presence: true

  has_many :tag_assignments
  has_many :tags, through: :tag_assignments

  property :id
  property :comment
  property :image_url
  collection :tags, selectable: true

  link(:self) { api_image_path(self) }
  link(:tags) { api_image_image_tags_path(self) }

  validate do
    if changed_attributes[:source_url]
      errors.add :source_url, 'source_url cannot be updated'
    end
  end

  scope :unduplicated, -> { where(duplication_id: nil) }
  scope :safe, -> { where(nsfw: false) }

  after_create :automirror

  def comment
    (self.read_attribute(:comment) || '').gsub(/<.+?>/, '')
  end

  def real_image_url
    if self.storage_path && Rails.application.secrets.storage_url
      "#{Rails.application.secrets.storage_url}/#{self.storage_path}"
    else
      source_url
    end
  end

  def image_url
    if Rails.application.secrets.camo
      Camo.new(Rails.application.secrets.camo, Rails.application.secrets.camo_url).url(real_image_url)
    else
      real_image_url
    end
  end

  def extension
    url_ext = File.extname(URI(source_url).path) rescue ''
    url_ext.empty? ? 'gif' : url_ext[1..-1]
  end

  def set_storage_path!
    self.storage_path = "v1/#{self.sha[-2, 2] || ?_}/#{self.sha[-4, 2] || ?_}/#{self.sha}.#{self.extension}"
  end

  def mirror!
    # XXX:
    Rails.logger.info "Mirroring #{self.inspect}"
    file = Tempfile.new("gjcase-mirror-#{self.id || Digest::SHA2.hexdigest(self.source_url)}")
    system("curl", self.source_url, out: file) or raise 'curl failed'
    file.rewind


    self.sha = IO.popen([*%w(openssl dgst -sha256), in: file], 'r') do |io|
      out = io.read.chomp
      _, status = Process.waitpid2(io.pid)
      raise 'openssl dgst -sha256 fail' unless status.success?
      out.split(' ').last
    end
    Rails.logger.info "Image(#{self.id}) mirror: sha256 = #{self.sha}"

    self.set_storage_path!
    Rails.logger.info "Image(#{self.id}) mirror: storage_path = #{self.storage_path}"

    bucket = Rails.application.secrets.storage_master_bucket
    s3 = Aws::S3::Client.new(region: Rails.application.secrets.storage_master_region)

    Rails.logger.info "Image(#{self.id}) mirror: head_object(bucket: #{bucket}, key: #{self.storage_path})"

    begin
      head = s3.head_object(bucket: bucket, key: self.storage_path)
      if head
        self.save!
        Rails.logger.info "Image(#{self.id}) mirror: skipping"
        return
      end
    rescue Aws::S3::Errors::NotFound
    end

    Rails.logger.info "Image(#{self.id}) mirror: put_object(bucket: #{bucket}, key: #{self.storage_path}, type: #{self.guessed_content_type})"

    file.rewind
    s3.put_object(
      bucket: bucket,
      key: self.storage_path,
      content_type: self.guessed_content_type,
      body: file,
    )

    Rails.logger.info "Image(#{self.id}) mirror: mirrored"

    self.save!
  ensure
    file.close! if file && !file.closed?
  end

  def guessed_content_type
    mime_type = MIME::Types.type_for(self.extension).first
    if mime_type
      mime_type.content_type
    else
      'application/octet-stream'
    end
  end

  private def automirror
    if Rails.application.secrets.automirror
      ImageMirrorJob.perform_async(self.id)
    end
  end
end
