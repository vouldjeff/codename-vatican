Delayed::Worker.logger = ActiveSupport::BufferedLogger.new(File.join(RAILS_ROOT, '/log/', "#{Rails.env}_delayed_jobs.log"), Rails.logger.level) 

class ExtractJob < Struct.new(:resource, :opts)
  def perform
    result = Extractor.by_name resource, opts || {}
    
    result
  end
end