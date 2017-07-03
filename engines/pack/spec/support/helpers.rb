module PackHelpers
	def access_with_status overrides=nil 
		access=FactoryGirl.build(:access,overrides)	
		access.save
		access
	end

	def access_with_status_without_validation overrides=nil 
		access=FactoryGirl.build(:access,overrides)	
		access.save(:validate => false)
		access
	end


	def jobs_array
		Pack::PackWorker.jobs.map{ |h| h['args']  }
	end	 

	def expect_sidekiq_mailer arr
		puts jobs_array.inspect
		expect(jobs_array).to eq arr

		arr.each do |a|
			a = a - ["access_changed"]
			Pack::Mailer.access_changed(a[0], *( a.drop(1)  ) ) .deliver!

		end

	end

 
end