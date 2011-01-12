class SchemaJob < Struct(:key)
  @@done_jobs = 0
  @@saved_types = {}
  
  def perform
    @entity = Entity.one_by_key(key)
    return if @entity.is_ok?
    
    time = Benchmark.realtime do
      # TODO: use ken
      
      
      
    end
  end
end