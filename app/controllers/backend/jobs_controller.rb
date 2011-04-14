class Backend::JobsController < ApplicationController
  
  before_filter :must_sign_in, :except => [:index, :log, :queue]

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
      flash[:error] = "Грешна заявка!"
      redirect_to new_backend_job_path 
    end
        
    if params[:jobs][:entities].nil?
      flash[:error] = "Не са посочени имена на ресурси за извличане!"
      redirect_to new_backend_job_path
    end
    
    priority = params[:jobs][:priority].to_i unless params[:jobs][:priority].nil?
    delay = params[:jobs][:delay].to_i.seconds.from_now unless params[:jobs][:delay].nil?
      
    opts = {:translate => params[:jobs][:translate]}
    i = 0
    
    params[:jobs][:entities].split("\r\n").each do |line|
      Delayed::Job.enqueue ExtractJob.new(line.strip, opts), priority, delay
      i += 1
    end
    
    flash[:notice] = "#{i} задачи бяха добавени в опашката."
    redirect_to queue_backend_jobs_path
  end
  
  def log
    @logs = JobLog.all
  end
  
  def destroy_log
    @log = JobLog.find(params[:id])
    raise MongoMapper::DocumentNotFound if @log.nil?
    
    if @log.destroy
      flash[:notice] = "Успешно изтрихте лога."
    else
      flash[:error] = "Грешка!"
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
      flash[:notice] = "Успешно премахнахте задачата."
    else
      flash[:error] = "Грешка!"
    end
    redirect_to queue_backend_jobs_path
  end
end
