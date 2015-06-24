class Image < ActiveRecord::Base
  include Garage::Representer

  validates :source_url, presence: true

  has_many :tag_assignments
  has_many :tags, through: :tag_assignments

  property :id
  property :comment
  property :image_url
  collection :tags, selectable: true

  link(:tags) { api_image_image_tags_path(self) }

  validate do
    if changed_attributes[:source_url]
      errors.add :source_url, 'source_url cannot be updated'
    end
  end

  scope :unduplicated, -> { where(duplication_id: nil) }

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
    file = Tempfile.new("gjcase-mirror-#{self.id || Digest::SHA2.hexdigest(self.source_url)}")
    system("curl", self.source_url, out: file) or raise 'curl failed'
    file.rewind

    self.sha = IO.popen([*%w(openssl dgst -sha256), in: file], 'r') do |io|
      out = io.read.chomp
      _, status = Process.waitpid2(io.pid)
      raise 'openssl dgst -sha256 fail' unless status.success?
      out
    end
    file.rewind

    self.set_storage_path!

    bucket = Rails.application.secrets.storage_master_bucket
    s3 = Aws::S3::Client.new(region: Rails.application.secrets.storage_master_region)

    begin
      head = s3.head_object(bucket: bucket, key: self.storage_path)
      return if head
    rescue Aws::S3::Errors::NotFound
    end

    s3.put_object(
      bucket: bucket,
      key: self.storage_path,
      content_type: self.guessed_content_type,
      body: file,
    )

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
end
