require 'open-uri'

class TumblrImportJob
  include Sidekiq::Worker

  def perform(tumblelog)
    Importer.new(tumblelog).run!
  end

  class TagImporter
    def initialize(tag_id, tumbletag, max_offset = 1000)
      @api_key = Rails.application.secrets.tumblr_key
      @tag = Tag.find(tag_id)
      @tumbletag = tumbletag
      @max_offset = max_offset
    end

    def run!
      payload = get_photos(0)

      break if payload['response'].empty?

      link_map = payload['response'].select{ |_| _['type'] == 'photo' && _['photos'] }.map do |item|
        [item['post_url'], comment: item['caption'], images: item['photos'].map { |_| _['original_size']['url'] rescue nil }.compact.select { |_| _.end_with?('.gif') }]
      end.to_h

      Image.where(source_identifier: link_map.keys).pluck(:source_identifier).each do |x|
        link_map.delete x
      end

      link_map.each do |link, x|
        log " * #{link}"

        x[:images].each do |url|
          comment = x[:comment]
          image = Image.create!(source_url: url, source_identifier: link, comment: comment, tags: [@tag])
          ImageMirrorJob.perform_async(image.id)
          log "   #{url} => #{image.id}"
        end
      end
    end

    def get_photos(offset=0)
      tag = URI.encode_www_form_component(@tumbletag)
      response = open("http://api.tumblr.com/v2/tagged?tag=#{tag}&&api_key=#{@api_key}&offset=#{offset}", 'r', &:read)
      JSON.parse(response)
    end

    private

    def log(msg)
      formatted = "[#{$$} TumblrImportJob(#{@tumblelog})] #{msg}"
      Rails.logger.info formatted
      puts formatted
    end
  end

  class Importer
    def initialize(tumblelog)
      @api_key = Rails.application.secrets.tumblr_key
      @tumblelog = tumblelog
    end

    def run!
      no_download_count = 0
      downloaded = true
      offset = 0
      while no_download_count < 10
        downloaded = false
        payload = get_photos(offset)
        log "=> Offset: #{offset}"

        break if payload['response']['posts'].empty?

        link_map = payload['response']['posts'].map do |item|
          [item['post_url'], comment: item['caption'], images: item['photos'].map { |_| _['original_size']['url'] rescue nil }.compact.select { |_| _.end_with?('.gif') }]
        end.to_h

        Image.where(source_identifier: link_map.keys).pluck(:source_identifier).each do |x|
          link_map.delete x
        end

        link_map.each do |link, x|
          log " * #{link}"

          x[:images].each do |url|
            downloaded = true
            comment = x[:comment]
            image = Image.create!(source_url: url, source_identifier: link, comment: comment)
            ImageMirrorJob.perform_async(image.id)
            log "   #{url} => #{image.id}"
          end
        end
        if downloaded
          no_download_count += 1 
        else
          no_download_count = 0
        end
        no_download_count = 0
        offset += 20
      end
    end

    def get_photos(offset=0)
      response = open("http://api.tumblr.com/v2/blog/#{@tumblelog}/posts/photo?api_key=#{@api_key}&offset=#{offset}", 'r', &:read)
      JSON.parse(response)
    end

    private

    def log(msg)
      formatted = "[#{$$} TumblrImportJob(#{@tumblelog})] #{msg}"
      Rails.logger.info formatted
      puts formatted
    end
  end
end
