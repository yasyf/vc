module External::ReactServerHelper
  def react_server_component(name, props, options = {})
    if Rails.env.development?
      react_client_component_div(name, props, options)
    else
      react_server_component_div(name, props, options) + react_server_component_script(name)
    end
  end

  private

  def react_server_component_script(name)
    code = <<-JS
      var root = document.getElementById('react-root-component');
      WebpackerReact.render(root, WebpackerReact.registeredComponents["#{name}"]);
    JS
    javascript_tag code
  end

  def react_server_component_div(name, props, options)
    body = ServerSideRendering::Render.render name, props
    Webpacker::React::Component.new(name).hydrate(body, props, options.reverse_merge(id: 'react-root-component'))
  end

  def react_client_component_div(name, props, options)
    Webpacker::React::Component.new(name).render(props, options)
  end
end