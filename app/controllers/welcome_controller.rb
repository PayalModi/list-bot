require 'net/http'
require 'uri'
require 'json'

class WelcomeController < ApplicationController
  def homepage
  	if request.post?
  		information = request.raw_post
		  data_parsed = JSON.parse(information)
		  respond_to_message(data_parsed)
  	else
  		verify_webhook(params["hub.mode"], params["hub.verify_token"], params["hub.challenge"])
  	end
  end

  def respond_to_message (data_parsed)
  	if data_parsed["object"] == 'page'
  		for entry in data_parsed["entry"] do
  			for event in entry["messaging"] do
  				senderID = event["sender"]["id"]
  				messageText = event["message"]["text"]
  				responseText = "Sorry I don't understand that yet. Try one of these phrases: start new list, show me the list, or add *"
  				messageText = messageText.downcase

  				if messageText.start_with?("add")
  					item = messageText[4..-1]
            ListItem.create(:itemname => item, :created_at => DateTime.now, :userid => senderID)
  					responseText = "Ok! I added " + item + " to the list."
  				elsif messageText == "hi" or messageText == "hello" or messageText == "hey"
  					responseText = "Hi there!"
  				elsif messageText == "start new list"
  					responseText = "Ok! Starting a new list!"
  				elsif messageText == "show me the list"
  					responseText = "This is the list so far: "
            items = ListItem.where(userid: senderID)
            puts items
            items.join(", ")
            puts items
            responseText = responseText + items
  				end

  				send_message(senderID, responseText)
  			end
  		end
  	end
  end

  def send_message (senderID, messageText)
  	uri = URI.parse("https://graph.facebook.com/v2.6/me/messages?access_token="+ENV["PAGE_ACCESS_TOKEN"])
  	response = {:recipient => {:id => senderID}, :message => {:text => messageText}}

  	http = Net::HTTP.new(uri.host, uri.port)
  	http.use_ssl = true
  	request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
  	request.body = response.to_json
  	http.request(request)
  end

  def verify_webhook (mode, token, challenge)
  	if (mode == 'subscribe' and token == ENV["VERIFY_TOKEN"] and challenge)
  		render plain: challenge, status: 200
  	else
  		head 200
	end
  end
end