require_relative '../common'

require 'json'
require 'nokogiri'
require 'prime'

## Exercise built by @freichel as a thank-you to @pil0u
# who organized and ran the LeWagon x AoC challlenge this year.

# Subject at bonus/exercises/26.md

module Bonus
  class Day26 < AdventDay

    USER_ID = 1

    class DatabaseFetcher < InputFetcher
      SESSION = ENV['LEWAGON_AOC_SESSION']
      LEWAGON_AOC_BASE_URL = 'https://aoc.lewagon.community'.freeze
      USER_PATH_SCHEME = '/stats/users/%{id}'.freeze

      def initialize(user_id)
        @user_id = user_id
      end

      def download_info
        return cache = JSON(File.read("tmp/26.#{@user_id}-keys.json")) if File.exist? 'tmp/26.keys.json'
        res = fetch(LEWAGON_AOC_BASE_URL + USER_PATH_SCHEME % { id: @user_id }, session_key: "_lewagon_aoc_session")

        name = Nokogiri::HTML(res.body).css('main h2').first.text
        table = Nokogiri::HTML(res.body).css('table')

        headers = table.css('tr')[1].css('th').map(&:text).uniq
        body = table.css('tr').map { |row| row.css('td').map(&:text) }.reject(&:empty?)
        scores = body.map do |row|
          part_1 = row[0...headers.count]
          part_2 = row[headers.count..-1]
          [headers.zip(part_1).to_h, headers.zip(part_2).to_h]
        end
        keys = scores.reverse.map do |(p1, p2)|
          [
            begin Integer(p1['Rank']) rescue -1 end,
            begin Integer(p2['Rank']) rescue -1 end,
          ]
        end
        user_info = { name: name, keys: keys }
        File.write("tmp/26.#{@user_id}-keys.json", user_info.to_json)
        user_info
      end
    end

    def first_part
      decryption_key.reduce(&:*)
    end

    def second_part
      decoded = input.map do |message|
        sender = message[:sender]
        decryption_key = decryption_key(sender)

        key = decryption_key.reduce(&:*) + (sender.even? ? sender : -sender)
        cipher = key.abs.digits.reverse.each_slice(3).map(&:first).join.to_i
        unshifted = unshift(message[:body], cipher)

        caesar_key = cipher.prime_division.map { |(factor, power)| factor * power }.sum
        caesar_key += 5 if cipher.prime?

        "#{name(sender)}: #{decode(unshifted, caesar_key)}\n\n"
      end
      display decoded
    end

    private

    def unshift(message, cipher)
      shifts = cipher.digits(3)
      shifts.each_with_index.reduce(message) do |body, (shift, pos)|
        case shift
        when 0 then body.reverse
        when 1 then body.chars.rotate.join
        when 2 then body.chars.rotate(-3**pos).join
        end
      end
    end

    ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzàéè0123456789 .!?,;:'-#/\\()".chars.freeze
    RUDOLPH = <<~TEXT.freeze
      You know Dasher, and Dancer, and
      Prancer, and Vixen,
      Comet, and Cupid, and
      Donder and Blitzen
      But do you recall
      The most famous reindeer of all


      Rudolph, the red-nosed reindeer
      had a very shiny nose
      and if you ever saw it
      you would even say it glows.

      All of the other reindeer
      used to laugh and call him names
      They never let poor Rudolph
      play in any reindeer games.

      Then one foggy Christmas eve
      Santa came to say:
      "Rudolph with your nose so bright,
      won't you guide my sleigh tonight?"

      Then all the reindeer loved him
      as they shouted out with glee,
      Rudolph the red-nosed reindeer,
      you'll go down in history!
    TEXT

    def decode(message, key)
      in_song_order = RUDOLPH.gsub(/[^\w]/, '').chars.uniq # Special characters stay at the end
      rudolphabet = in_song_order | ALPHABET
      message.chars.map do |char|
        initial_position = rudolphabet.index(char)
        new_position = (initial_position + key) % rudolphabet.length
        rudolphabet[new_position]
      end.join
    end

    def name(user_id = USER_ID)
      DatabaseFetcher.new(user_id).download_info[:name]
    end

    def encryption_key(user_id = USER_ID)
      DatabaseFetcher.new(user_id).download_info[:keys].transpose.first
    end

    def decryption_key(user_id = USER_ID)
      DatabaseFetcher.new(user_id).download_info[:keys].transpose.last
    end

    def convert_data(data)
      super.map do |message|
        sender, body = message.match(/^(\d+): (.*)$/).captures
        { sender: sender.to_i, body: body }
      end
    end
  end
end

Bonus::Day26.solve
