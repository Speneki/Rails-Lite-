require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req, @res = req, res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    if already_built_response?
      raise "PROBLEM"
    end
    res.status = 302
    # res.location = url
    res['Location'] = url
    @already_built_response = true
    session.store_session(res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    if already_built_response?
      raise "PROBLEM"
    end
    res.set_header("Content-Type", content_type)
    res.write(content)
    @already_built_response = true
    session.store_session(res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    if already_built_response?
      raise "PROBLEM"
    end
    controller_name = self.class.to_s.underscore
    filepath = "./views/#{controller_name}/#{template_name}.html.erb"
    raw_content = File.read(filepath)
    render_content(ERB.new(raw_content).result(binding), 'text/html')
    session.store_session(res)
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

