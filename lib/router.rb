require "byebug"

class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
      @pattern, @http_method, @controller_class, @action_name = pattern, http_method, controller_class, action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    path = req.path
    method = req.request_method
    regex = Regexp.new(@pattern)
    return true if regex =~ path && http_method == method.downcase.to_sym
    false
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    regex = Regexp.new(@pattern)
    path = req.path

    match_data = regex.match(path)
    route_params = {}
    match_data.names.each do |name|
      route_params[name] = match_data[name]
    end
    my_controller = @controller_class.new(req, res, route_params)

    my_controller.invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  # get Regexp.new("^/cats$"), Cats2Controller, :index
  def draw(&proc)
    self.instance_eval(&proc)
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  # should return the route that matches this request
  def match(req)
    @routes.each do |route|
      # p "\n route method: #{route.http_method}, pattern: #{route.pattern} \n"
      return route if route.matches?(req)
    end
    nil
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    # p "\n\n\n ----My Route method: #{req.request_method} path: #{req.path}"
    route = match(req)
    if route
      route.run(req, res)
    else
      res.status = 404
    end
  end
end
