require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = req.params.merge(route_params)
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "already_built_response" if @already_built_response
    @already_built_response = true

    session.store_session(@res)
    flash.store_session(@res)

    @res["location"] = url
    @res.status = 302
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "already_built_response" if @already_built_response
    @already_built_response = true

    session.store_session(@res)
    flash.store_session(@res)

    @res['Content-Type'] = content_type
    @res.body = [content]
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    path = "views" + "/" + self.class.to_s.underscore + "/" + template_name.to_s + ".html.erb"
    template_contents = File.read(path)
    template_contents = ERB.new(template_contents).result(binding)
    render_content(template_contents, "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name.to_sym)
    render(name) unless @already_built_response
  end
end
