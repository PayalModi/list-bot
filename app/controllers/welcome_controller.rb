class WelcomeController < ApplicationController
  def homepage
  	puts "Reached homepage"
  	if request.post?
  		puts params
  		information = request.raw_post
		data_parsed = JSON.parse(information)
  		puts data_parsed
  	else
  		if params["hub.mode"] == 'subscribe' and params["hub.verify_token"] == ENV["VERIFY_TOKEN"] and params["hub.challenge"]
	  		render plain: params["hub.challenge"], status: 200
	  	else
	  		head 200
  		end
  	end
  end
end