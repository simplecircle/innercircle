class GoogleAnalyticsParser
  def parse(cookie)
    begin
      arr = cookie.scan(/utmz[^;]+/i)

      if arr.empty?
        return ""
      else
        utmz = arr[0]
      end
      
      if arr.length > 1
        #Get the cookie with the earliest timestamp
        begin
          arr.each do |str|
            timestamp_existing = utmz.match(/\d\.(\d+)\./)[1]
            timestamp_new = str.match(/\d\.(\d+)\./)[1]
            utmz = str if !timestamp_new.nil? && timestamp_new < timestamp_existing
          end
        end
      end

      referral_array = []
      referral_hash = {}

      ga_source = utmz.match(/utmcsr=([^\|]+)/)
      ga_campaign = utmz.match(/utmccn=([^\|]+)/)
      ga_medium = utmz.match(/utmcmd=([^\|]+)/)
      ga_keyword = utmz.match(/utmctr=([^\|]+)/)
      ga_ad_content = utmz.match(/utmcct=([^\|]+)/)

      def nil_or_value(val)
        val.nil? ? '' : val[1]
      end

      referral_hash = {
        :source => nil_or_value(ga_source),
        :campaign => nil_or_value(ga_campaign),
        :medium => nil_or_value(ga_medium),
        :keyword => nil_or_value(ga_keyword),
        :ad_content => nil_or_value(ga_ad_content)
      }.to_s
    rescue 
      return ""
    end
  end
end