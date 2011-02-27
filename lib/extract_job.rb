Delayed::Worker.logger = ActiveSupport::BufferedLogger.new(File.join(RAILS_ROOT, '/log/', "#{Rails.env}_delayed_jobs.log"), Rails.logger.level) 

class ExtractJob < Struct.new(:resource, :opts)
  def perform
    time = Time.now
    begin
      result = Extractor.by_name resource, opts || {}
      
      JobLog.create(:status => :success, :job_type => :extract, :info => result, :time => Time.now - time)
    rescue ExtractError => e
      code, info = *e.message
      JobLog.create(:status => :failed, :job_type => :extract, :error_code => code, :info => info, :time => Time.now - time)
    end
  end
  
  def error(job, e)
    JobLog.create(:status => :exception, :job_type => :extract, :info => e.to_yaml)
  end
end