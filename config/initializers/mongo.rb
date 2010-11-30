MongoMapper.connection = Mongo::Connection.new('localhost', 27017, :logger => Rails.logger)
MongoMapper.database = "vatican_dev"

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    MongoMapper.connection.connect_to_master if forked
  end
end
