class Backend::JobsController < ApplicationController
  # TODO: add administrator protection
  
  def index
  end
  
  def queue
    @jobs = Delayed::Backend::MongoMapper::Job.sort(:run_at).all
  end
  
  def destroy
    @job = Delayed::Backend::MongoMapper::Job.find(params[:id])
    
    if @job.destroy
      flash[:notice] = "succ-destroy-job"
    else
      flash[:error] = "error"
    end
    redirect_to queue_backend_jobs_path
  end
end
