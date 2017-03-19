require "./FraBot/*"
require "TelegramBot"

module FraBot

  begin
    token = File.read("token").gsub("\n","")
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

      end
    end
  end

  my_bot = FraBot.new token
  my_bot.polling
end
