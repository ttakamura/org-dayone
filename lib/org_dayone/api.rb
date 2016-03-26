# coding: utf-8
require "tempfile"

module OrgDayone
  class API
    include Logging

    def create body, date: nil
      try_create(body) do
        journal_option = "-j='~/Library/Group Containers/5U8NS4GX82.dayoneapp2/Data/Auto Import/Default Journal.dayone'"
        date_option    = date ? "--date='#{date}' " : " "

        file = Tempfile.new('dayone')
        begin
          file.write body
          file.flush
          cmd = "cat #{file.path} | dayone #{journal_option} #{date_option} new"
          puts cmd
          res = `#{cmd}`.chomp
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
    end

    def create_by_ifttt body, secret: ENV['IFTTT_SECRET']
      try_create(body) do
        event = 'post_dayone'
        response = HTTParty.post("https://maker.ifttt.com/trigger/#{event}/with/key/#{secret}", {
                                   body: {value1: body}.to_json,
                                   headers: {'Content-Type' => 'application/json'}
                                 })
        if response.code == 200
          log.info response.body
          commit body, rand.to_s
        else
          log.error response.inspect
          raise response.body
        end
        response
      end
    end

    private
    def try_create body, &block
      if has_post?(body)
        log.info "Skip already posted in DayOne - #{body}"
        return false
      else
        log.info "Create new post - #{body}"
        block.call
      end
    end

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
