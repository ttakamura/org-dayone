module OrgDayone
  class << self
    def api
      @api ||= OrgDayone::API.new
    end

    def db
      @db ||= OrgDayone::DB.new("db/dayone.yaml")
    end
  end
end

require 'org_dayone/api'
require 'org_dayone/db'
require 'org_dayone/headline'
