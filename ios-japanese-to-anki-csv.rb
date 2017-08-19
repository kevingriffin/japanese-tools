#! /usr/bin/env ruby
require "csv"

Entry = Struct.new(:word, :reading, :meaning)

class Parser
  class << self
    def run(file_path)
      convert_to_entries(break_into_paragraphs(strip_footer(read_file(file_path))))
    end

    def read_file(path)
      File.read(path)
    end

    def strip_footer(text)
      text.chomp("\n\n\n\nCreated with Japanese for iOS®\n\n")
    end

    def break_into_paragraphs(text)
      text.split(/\n\n/).map { |entry| entry.split(/\n/) }
    end

    def convert_to_entries(paragraphs)
      paragraphs.map do |paragraph|
        unless paragraph.length == 2
          raise ArgumentError.new("Extra data in word: #{paragraph}")
        end

        word_with_reading = paragraph.first.chomp || ""
        word, reading     = word_with_reading.match(/([\p{Han}|\p{Hiragana}|\p{Katakana}]+)(?:（(\p{Hiragana}+)）)?/).captures
        reading           = word if reading.nil? || reading.empty?

        if word.empty? || reading.empty?
          raise ArgumentError.new("Couldn't parse word from #{word_with_reading}. #{word} #{reading}")
        end

        meaning = paragraph.last

        if meaning.nil? || meaning.empty?
          raise ArgumentError.new("Couldn't find meaning in #{paragraph}")
        end

        Entry.new(word, reading, meaning)
      end
    end
  end
end

class Output
  def self.run(output_filename, entries)
    CSV.open(output_filename, "wb") do |csv|
      entries.each do |entry|
        csv << [entry.word, entry.meaning, entry.reading]
      end
    end
  end
end

if __FILE__ == $0
  Output.run(ARGV[1], Parser.run(ARGV[0]))
end
