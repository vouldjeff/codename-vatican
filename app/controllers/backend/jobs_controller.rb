class Backend::JobsController < ApplicationController
  # TODO: add administrator protection
  
  def index
    @counters = {:queue => nil, :logs => {}}
    
    @counters[:queue] = Delayed::Backend::MongoMapper::Job.count
    @counters[:logs][:all] = JobLog.count
    @counters[:logs][:failed] = JobLog.where(:status => :failed).count
    @counters[:logs][:success] = JobLog.where(:status => :success).count
    @counters[:logs][:exception] = JobLog.where(:status => :exception).count
  end
  
  def new
  end
  
  def create
    if params[:jobs].nil?
      flash[:error] = "no params"
      redirect_to new_backend_job_path 
    end
        
    if params[:jobs][:entities].nil?
      flash[:error] = "no entities filled."
      redirect_to new_backend_job_path
    end
    
    priority = params[:jobs][:priority].to_i unless params[:jobs][:priority].nil?
    delay = params[:jobs][:delay].to_i.seconds.from_now unless params[:jobs][:delay].nil?
      
    opts = {}
    i = 0
    
    params[:jobs][:entities].split("\r\n").each do |line|
      Delayed::Job.enqueue ExtractJob.new(line.strip, opts), priority, delay
      i += 1
    end
    
    flash[:notice] = "#{i} jobs added to queue."
    redirect_to queue_backend_jobs_path
  end
  
  def log
    @logs = JobLog.all
  end
  
  def destroy_log
    @log = JobLog.find(params[:id])
    raise MongoMapper::DocumentNotFound if @log.nil?
    
    if @log.destroy
      flash[:notice] = "succ-destroy-job-log"
    else
      flash[:error] = "error"
    end
    redirect_to log_backend_jobs_path
  end
  
  def queue
    @jobs = Delayed::Backend::MongoMapper::Job.sort(:run_at).all
  end
  
  def destroy
    @job = Delayed::Backend::MongoMapper::Job.find(params[:id])
    raise MongoMapper::DocumentNotFound if @job.nil?
    
    if @job.destroy
      flash[:notice] = "succ-destroy-job"
    else
      flash[:error] = "error"
    end
    redirect_to queue_backend_jobs_path
  end
end
