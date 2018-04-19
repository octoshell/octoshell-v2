module Pack
  class PackWorker
    include Sidekiq::Worker
    sidekiq_options retry: 2, queue: :pack_worker
   
    def perform(template, args='default')
    	
    	if template=="expired"
    		Pack::Access.expired_accesses
            Pack::Version.expired_versions
    	
       
        else
        	Pack::Mailer.send(template, *args).deliver_now!

        end
    end
    

  end
end
