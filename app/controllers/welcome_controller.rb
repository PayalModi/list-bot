require 'net/http'
require 'uri'
require 'json'

class WelcomeController < ApplicationController
  def homepage
  	if request.post?
  		information = request.raw_post
		data_parsed = JSON.parse(information)
  		puts data_parsed
	  	if data_parsed["object"] == 'page'
	  		for entry in data_parsed["entry"] do
	  			for event in entry["messaging"] do
	  				senderID = event["sender"]["id"]
	  				messageText = event["message"]["text"]
	  				puts messageText
	  				puts senderID

	  				uri = URI.parse("https://graph.facebook.com/v2.6/me/messages?access_token="+ENV["PAGE_ACCESS_TOKEN"])
	  				header = {'Content-Type': 'text/json'}
	  				response = {recipient: {id: senderID}, message: {text: messageText}}

	  				http = Net::HTTP.new(uri.host, uri.port)
	  				request = Net::HTTP::Post.new(uri.request_uri, header)
	  				request.body = response.to_json
	  				puts response
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