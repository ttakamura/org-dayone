module OrgDayone
  class Headline
    attr_reader :sub_headlines

    def self.parse io
      parser = Orgmode::Parser.new(io.read)

      current_h = parser.headlines.shift
      sub_headlines = []
      top_headlines = []

      parser.headlines.each do |h|
        if current_h.level < h.level
          sub_headlines << self.new(h)
        else
          top_headlines << self.new(current_h, sub_headlines)
          current_h     = h
          sub_headlines = []
        end
      end
      top_headlines << self.new(current_h, sub_headlines)

      top_headlines
    end

    def initialize headline, sub_headlines=[]
      @headline = headline
      @sub_headlines = sub_headlines
    end

    def level
      @headline.level
    end

    def to_markdown
      normalize [
        title,
        "",
        body,
        @sub_headlines.map{ |h| h.to_markdown },
        ""
      ].flatten.compact.join("\n")
    end

    def title
      @headline.headline_text.to_s
    end

    def body
      parse_body_lines @headline.body_lines
    end

    private
    def normalize text
      text.gsub(/\[\[([^\]]+)\]\]/, "\\1")
          .gsub(/\[\[[^\]]+\]\[([^\]]+)\]\]/, "\\1")
    end

    def parse_body_lines body_lines
      body_lines.map do |body_line|
        case body_line.paragraph_type
        when :metadata
          # TODO
          nil
        when :list_item
          body_line.to_s.gsub(/^\s+/,"")
        when :paragraph
          body_line.to_s.gsub(/^\s+/,"")
        else
          nil
        end
      end.compact
    end
  end
end
