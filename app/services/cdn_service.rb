class CdnService

  def self.generate_cloud_front_url(path)
    host = ENV.fetch('CONTESTS_CLOUD_FRONT_HOST').to_s
    return host + path
  end
end