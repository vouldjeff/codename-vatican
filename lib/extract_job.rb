class ExtractJob < Struct.new(:resource, :opts, :by_key)
  def perform
    @extractor = nil
    begin
      time = Benchmark.realtime do
        @extractor = Extractor.new resource, by_key || false
        @extractor.run(opts || {})
      end
    rescue ExtractError => e
      code, info = *e.message
      info ||= resource
      @extractor.rollback() unless @extractor.nil? 
      JobLog.create(:status => :failed, :job_type => :extract, :error_code => code, :info => info, :time => nil)
    else
      JobLog.create(:status => :success, :job_type => :extract, :info => @extractor.result, :time => time)
    ensure
      @extractor = nil
    end
  end
  
  def error(job, e)
    JobLog.create(:status => :exception, :job_type => :extract, :info => e.to_yaml)
  end
end
