class Flash

  def initialize(req)
    @stale_cookies = {}
    puts "\n cookies #{req.cookies}"
    if req.cookies["_flash"]
      @stale_cookies = JSON.parse(req.cookies["_flash"])
    end
    # @temp_cookies = {}
    @fresh_cookies = {}
  end

  def now(key, val)
    @stale_cookies[key] = val
  end

  def [](key)
    puts "\n --------- stale_cookies #{@stale_cookies}, fresh_cookies #{@fresh_cookies}, temp_cookies #{@temp_cookies}"
    @stale_cookies[key]
  end

  def []=(key, val)
    @fresh_cookies[key] = val
  end

  def store_session(res)
    res.set_cookie("_flash", {value: @fresh_cookies.to_json, path: "/"})
  end

end
