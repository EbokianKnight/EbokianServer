require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params = {})
    @req = req
    @res = res
    @params = params
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  def record_response
    @already_built_response = true
  end

  def mark_cookie
    @session.store_session(@res) if @session
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "ERROR" if already_built_response?
    @res['location'] = url
    @res.status = 302
    mark_cookie
    record_response
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "ERROR" if already_built_response?
    @res['Content-Type'] = content_type
    @res.write(content)
    mark_cookie
    record_response
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller = self.class.to_s.underscore
    url = "views/#{controller}/#{template_name}.html.erb"
    erb = ERB.new(File.read(url)).result(binding)
    render_content(erb, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?
  end
end
