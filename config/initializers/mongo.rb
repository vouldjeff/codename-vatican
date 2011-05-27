MongoMapper.connection = Mongo::Connection.new('mongodb', 27017, :logger => Rails.logger)
MongoMapper.database = "vatican"

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    MongoMapper.connection.connect if forked
  end
end
