class WelcomeController < ApplicationController
  def homepage
  	if params["hub.mode"] == 'subscribe' and params["hub.verify_token"] == ENV["VERIFY_TOKEN"] and params["hub.challenge"]
  		render plain: params["hub.challenge"], status: 200
  	else
  		head 200
  	end
  end
end
