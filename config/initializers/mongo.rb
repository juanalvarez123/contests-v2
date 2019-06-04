Mongoid.configure do |config|
  config.clients.default = {
      hosts: [ENV.fetch('CONTESTS_DATABASE_HOST', '127.0.0.1') + ':27017'],
      database: ENV.fetch('CONTESTS_DATABASE_NAME', 'contests'),
      options: {
          user: ENV.fetch('CONTESTS_DATABASE_USER', 'root'),
          password: ENV.fetch('CONTESTS_DATABASE_PASSWORD', '12345')
      }
  }

  config.log_level = :warn
end
