class WelcomeController < ApplicationController
  def homepage
  	if request.post?
  		information = request.raw_post
		data_parsed = JSON.parse(information)
  		puts data_parsed
	  	if data_parsed["object"] == 'page'
	  		for entry in data_parsed["entry"] do
	  			for event in entry["messaging"] do
	  				puts event["message"]["text"]
	  			end
	  		end
	  	end
  	else
  		if params["hub.mode"] == 'subscribe' and params["hub.verify_token"] == ENV["VERIFY_TOKEN"] and params["hub.challenge"]
	  		render plain: params["hub.challenge"], status: 200
	  	else
	  		head 200
  		end
  	end
  end
end