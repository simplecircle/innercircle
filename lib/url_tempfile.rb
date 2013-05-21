class URLTempfile < Tempfile
  def initialize(url, tmpdir = Dir.tmpdir, options)
    @url = URI.parse(url)
    begin
      super(['url', '.jpg'], tmpdir, options)
      Net::HTTP.start(@url.host) do |http|
        self.write http.get(@url.path).body
      end
    ensure
    end
  end
end

