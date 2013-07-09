require 'open-uri'

class Mailchimp
  @@api_key = '01e6669645e669e5ad44a5a473f3fc19-us7'
  @@api_base = 'http://us7.api.mailchimp.com/1.3/'

  def ping
    url = "#{@@api_base}?method=ping&apikey=#{@@api_key}&output=json"
    res = open(url)
    res.read
  end

  def list_subscribe list_id, email
    url = "#{@@api_base}?method=listSubscribe&apikey=#{@@api_key}&id=#{list_id}&merge_vars[OPTIN_IP]=remote_ip&email_address=#{email}&update_existing=true&double_optin=false&output=json"
    res = open(url)
    res.read == "true"
  end
end