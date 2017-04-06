require "./FraBot/*"
require "TelegramBot"
require "http/client"

module FraBot
  begin
    token = File.read("token").gsub("\n", "")
  rescue ex
    puts "File token not found"
    exit
  end

  puts "Starting FraBot"

  class FraBot < TelegramBot::Bot
    def initialize(token)
      super("FraBot", token)
    end

    def handle(message : TelegramBot::Message)
      puts message
      if message.text
        from = message.from
        text = message.text

        return unless from.is_a?(TelegramBot::User)
        return unless text.is_a?(String)

        if /zero/i.match(text)
          reply(message, "We")
        end

        if /^!calc/i.match(text)
          matches = /^!calc (.*?)$/i.match(text)
          return unless matches
          expr = matches[1].to_s || ""
          if !expr
            expr = ""
          end
          HTTP::Client.get("http://api.mathjs.org/v1/?expr=#{URI.escape expr}") do |response|
            reply(message, response.body_io.gets_to_end)
          end
        end

        if /^\/r\/[A-z0-9]+$/.match(text)
          matches =  /^\/r\/(.*?)$/.match(text)
          puts matches
          return unless matches
          HTTP::Client.get("https://www.reddit.com/r/#{matches[1]}.json") do |response|
            json = JSON.parse(response.body_io.gets_to_end)
            els = json["data"]["children"]

            msg = "Posts of /r/#{matches[1]}\n\n"
            count = 0
            els.each do |el|
              break unless count<5
              msg += el["data"]["title"].to_s
              msg += "\n"
              msg += "https://reddit.com/#{el["data"]["permalink"].to_s}"
              msg += "\n\n"
              count+= 1
            end
            reply(message, msg)
          end
        end
      end
    end
  end

  my_bot = FraBot.new token
  my_bot.polling
end

require "http/client"
