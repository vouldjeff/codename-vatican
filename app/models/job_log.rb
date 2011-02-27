class JobLog
  include MongoMapper::Document
  plugin MongoMapper::Plugins::Timestamps
  timestamps!
  
  key :status, Symbol, :required => true
  key :job_type, Symbol, :required => true
  key :error_code, Symbol
  key :info
  key :time, Float
  
end