require 'open-uri'

class Mailchimp
  @@api_key = '01e6669645e669e5ad44a5a473f3fc19-us7'
  @@api_base = 'http://us7.api.mailchimp.com/1.3/'
  @@list_id = '12cc45a9d8'

  def ping
    url = "#{@@api_base}?method=ping&apikey=#{@@api_key}&output=json"
    res = open(url)
    res.read
  end

  def list_subscribe(user)
    begin
      category = user.profile.profiles_company_depts.first.company_dept.name
      category = user.profile.profiles_company_depts.first.other_job_category if category == "other"
      companies = user.users_companies.map{|uc| uc.company.name}.join(',')
      fname = user.profile.first_name
      fname ||= ""
      lname = user.profile.last_name
      lname ||= ""

      url = "#{@@api_base}?method=listSubscribe&apikey=#{@@api_key}&id=#{@@list_id}&merge_vars[OPTIN_IP]=remote_ip&merge_vars[CATEGORY]=#{CGI.escape(category)}&merge_vars[COMPANIES]=#{CGI.escape(companies)}&merge_vars[FNAME]=#{CGI.escape(fname)}&merge_vars[LNAME]=#{CGI.escape(lname)}&email_address=#{user.email}&update_existing=true&double_optin=false&output=json"
      res = open(url)

    rescue
      # Try without merge vars
      url = "#{@@api_base}?method=listSubscribe&apikey=#{@@api_key}&id=#{@@list_id}&merge_vars[OPTIN_IP]=remote_ip&email_address=#{user.email}&update_existing=true&double_optin=false&output=json"
      res = open(url)
    end
    res.read == "true"
  end
end