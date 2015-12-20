# coding: utf-8
require "tempfile"

module OrgDayone
  class API
    include Logging

    def create body, date: nil
      if has_post?(body)
        log.info "Skip already posted in DayOne - #{body}"
        return false
      else
        log.info "Create new post - #{body}"
      end

      date_option = date ? "--date='#{date}' " : " "

      file = Tempfile.new('dayone')
      begin
        file.write body
        file.flush
        res = `cat #{file.path} | dayone #{date_option} new`.chomp
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
