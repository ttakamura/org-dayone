# coding: utf-8
require "tempfile"

module OrgDayone
  class API
    def create body
      if has_post?(body)
        puts "Skip already posted in DayOne - #{body}"
        return false
      end

      file = Tempfile.new('dayone')
      begin
        file.write body
        file.flush
        res = `cat #{file.path} | dayone new`.chomp
        if m = res.match(/New entry : (.+)$/)
          commit body, m[1]
          true
        else
          raise "Invalid the response from DayOne - #{res}"
        end
      ensure
        file.close!
      end
    end

    private
    def has_post? body
      !!OrgDayone.db[signature_of(body)]
    end

    def commit body, dayone_id
      OrgDayone.db[signature_of(body)] = dayone_id
    end

    def signature_of body
      Digest::SHA256.hexdigest(body)
    end
  end
end
