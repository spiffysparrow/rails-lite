require "byebug"

class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    # p "pattern,#{pattern} http_method,#{http_method} controller_class,#{controller_class} action_name #{action_name}"
    @pattern, @http_method, @controller_class, @action_name = pattern, http_method, controller_class, action_name

  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    path = req.path
    method = req.request_method
    regex = Regexp.new(@pattern)
    return true if regex.match(path) && http_method == method.downcase.to_sym
    false
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    regex = Regexp.new(@pattern)
    # path = req.path
    # match_data = regex.match(path)
    #
    # params[]
    #
    # if match_data[2]
    #   p "asfdlkjsdf"
    #    match_data[2]
    # end
    my_controller = @controller_class.new(req, res, {})
    # p my_controller
    my_controller.send(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |http_method|
  end

  # should return the route that matches this request
  def match(req)
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
  end
end
