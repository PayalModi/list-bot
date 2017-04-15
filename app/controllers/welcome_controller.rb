class WelcomeController < ApplicationController
  def homepage
  	if request.post?
  		information = request.raw_post
		data_parsed = JSON.parse(information)
  		puts data_parsed
  		puts data_parsed["entry"][0]["messaging"][0]["message"]["text"]
  	else
  		if params["hub.mode"] == 'subscribe' and params["hub.verify_token"] == ENV["VERIFY_TOKEN"] and params["hub.challenge"]
	  		render plain: params["hub.challenge"], status: 200
	  	else
	  		head 200
  		end
  	end
  end
end