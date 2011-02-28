Delayed::Worker.logger = ActiveSupport::BufferedLogger.new(File.join(RAILS_ROOT, '/log/', "#{Rails.env}_delayed_jobs.log"), Rails.logger.level) 

class ExtractJob < Struct.new(:resource, :opts)
  def perform
    time = Time.now
    begin
      extractor = Extractor.new resource
      extractor.run(opts || {})
    rescue ExtractError => e
      code, info = *e.message
      info ||= resource
      extractor.rollback() unless extractor.nil? 
      JobLog.create(:status => :failed, :job_type => :extract, :error_code => code, :info => info, :time => Time.now - time)
    else
      JobLog.create(:status => :success, :job_type => :extract, :info => extractor.result, :time => Time.now - time)
    ensure
      extractor = nil
    end
  end
  
  def error(job, e)
    JobLog.create(:status => :exception, :job_type => :extract, :info => e.to_yaml)
  end
end