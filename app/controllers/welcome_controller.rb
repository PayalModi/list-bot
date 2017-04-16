require 'net/http'
require 'uri'
require 'json'

class WelcomeController < ApplicationController
  def homepage
  	if request.post?
  		information = request.raw_post
		data_parsed = JSON.parse(information)
	  	if data_parsed["object"] == 'page'
	  		for entry in data_parsed["entry"] do
	  			for event in entry["messaging"] do
	  				senderID = event["sender"]["id"]
	  				messageText = event["message"]["text"]

	  				uri = URI.parse("https://graph.facebook.com/v2.6/me/messages?access_token="+ENV["PAGE_ACCESS_TOKEN"])
	  				response = {:recipient => {:id => senderID}, :message => {:text => messageText}}

	  				http = Net::HTTP.new(uri.host, uri.port)
	  				http.use_ssl = true
	  				request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
	  				request.body = response.to_json
	  				http.request(request)
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