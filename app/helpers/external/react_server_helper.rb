module External::ReactServerHelper
  def react_server_component(name, props, options = {})
    react_server_component_div(name, props, options) + react_server_component_script(name)
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
    server_pack = ServerSideRendering::WebpackerManifestContainer.new.find_asset('server_side_render.js')
    body = ServerSideRendering::ExecJs.new(server_pack).render name, props
    Webpacker::React::Component.new(name).hydrate(body, props, options.reverse_merge(id: 'react-root-component'))
  end
end