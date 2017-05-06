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
          if event["message"]
            messageText = event["message"]["text"]
            messageText = messageText.downcase
            if event["message"]["quick_reply"]
              if messageText == "start new list"
                items = ListItem.where(userid: senderID)
                for item in items do
                  item.destroy
                end
                send_text_message(senderID, "Ok! Starting a new list!")
              elsif messageText == "show me the list"
                responseText = "This is the list so far:"
                items = ListItem.where(userid: senderID)
                for item in items do
                  responseText = responseText + "\n" + item[:itemname]
                end
                send_text_message(senderID, responseText)
              elsif messageText == "delete an item"
                send_delete_quick_reply(senderID)
              else
                send_text_message(senderID, "Ok. Deleting that item.")
              end

            elsif messageText.start_with?("add")
              item = messageText[4..-1]
              ListItem.create(:itemname => item, :created_at => DateTime.now, :userid => senderID)
              responseText = "Ok! I added " + item + " to the list."
              send_text_message(senderID, responseText)

            else
              send_initial_quick_reply(senderID)
            end
          end
        end
      end
    end
  end

  def send_text_message (senderID, messageText)
  	response = {:recipient => {:id => senderID}, :message => {:text => messageText}}
    send_message(response)
  end

  def send_button_message (senderID)
    response = {:recipient => {:id => senderID}, :message => {:attachment => {:type => "template", :payload => {:template_type => "generic", :elements => [{:title => "soda", :buttons => [{:type => "postback", :title => "Delete Item", :payload => "delete item 1"}]}]}}}}
    send_message (response)
  end

  def send_initial_quick_reply(senderID)
    response = {:recipient => {:id => senderID}, :message => {:text => "Pick one of these options, or type add * to add something to the list.", :quick_replies => [{:content_type => "text", :title => "Start new list", :payload => "new list"}, {:content_type => "text", :title => "Show me the list", :payload => "show list"}, {:content_type => "text", :title => "Delete an item", :payload => "delete item"}
]}}
    send_message(response)
  end

  def send_delete_quick_reply (senderID)
    response = {:recipient => {:id => senderID}, :message => {:text => "Pick an item to delete", :quick_replies => [{:content_type => "text", :title => "Soda", :payload => "Chose soda"}, {:content_type => "text", :title => "Potatoes", :payload => "Chose potatoes"}]}}
    send_message(response)
  end

  def send_message (response)
    uri = URI.parse("https://graph.facebook.com/v2.6/me/messages?access_token="+ENV["PAGE_ACCESS_TOKEN"])
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