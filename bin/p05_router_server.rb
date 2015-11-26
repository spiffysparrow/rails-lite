require 'rack'
require_relative '../lib/controller_base'
require_relative '../lib/router'


$cats = [
  { id: 1, name: "Curie" },
  { id: 2, name: "Markov" }
]

$statuses = [
  { id: 1, cat_id: 1, text: "Curie loves string!" },
  { id: 2, cat_id: 2, text: "Markov is mighty!" },
  { id: 3, cat_id: 1, text: "Curie is cool!" }
]

class StatusesController < ControllerBase
  def index
    statuses = $statuses.select do |s|
      s[:cat_id] == Integer(params['cat_id'])
    end

    render_content(statuses.to_s, "text/text")
  end
end

class CatsController < ControllerBase
  def index
    @cats = $cats
    # render_content($cats.to_s, "text/text")
  end
  def new
    @cat = {owner: nil, name: nil}
  end

  def create
    @cat = {owner: nil, name: nil}
    @cat = {owenr: @params["cat"]["owner"], name: @params["cat"]["name"]}

    # render_content(@cat.to_json, "text/html")
    if @cat.values.include?("")
      flash.now(:errors, "Fill out all values")
      render :new
    else
      flash["messages"] = "Stored your cat!"
      $cats << @cat
      redirect_to("/cats")
    end
  end
end

router = Router.new

router.add_route(Regexp.new("^/cats$"), :get, CatsController, :index)
router.add_route(Regexp.new("^/cats/new$"), :get, CatsController, :new)
router.add_route(Regexp.new("^/cats$"), :post, CatsController, :create)
router.add_route(("^/cats/(?<cat_id>\\d+)/statuses$"), :get, StatusesController, :index)

# router.draw do
#   get Regexp.new("^/cats$"), Cats2Controller, :index
#   get Regexp.new("^/cats/(?<cat_id>\\d+)/statuses$"), StatusesController, :index
# end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

Rack::Server.start(
 app: app,
 Port: 3000
)
