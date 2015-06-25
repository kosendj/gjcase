redis_conn = proc do
  Redis::Namespace.new(:gjcase, redis: Redis.new(url: ENV[ENV['REDIS_PROVIDER'] || 'REDIS_URL']))
end

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 9, &redis_conn)
end

Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: 25, &redis_conn)
end
