require 'openssl'

class Camo
  def initialize(camo_url, key)
    @camo_url, @key = camo_url, key
  end


  def url(url)
    "#{@camo_url}/#{digest(url)}/#{hex_encode(url)}"
  end

  private

  def digest(url)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), @key, url)
  end

  def hex_encode(url)
    url.each_byte.map { |byte| "%02x" % byte }.join
  end
end
