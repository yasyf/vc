# this is heavily influenced by react-rails:
# https://github.com/reactjs/react-rails/blob/master/lib/react/server_rendering/exec_js_renderer.rb
class ServerSideRendering::Backends::Base
  include External::ApplicationHelper

  JS_TEMPLATE = <<~JS
    var execJsGlobal = {};
    var global = global || this;
    var self = self || this;
    var window = window || this;
  JS

  def self.polyfills
    path = Rails.root.join('app', 'javascript', 'helpers', 'polyfills', '*.js')
    Dir[path].map { |f| File.read(f) }.join("\n")
  end

  def self.prelude
    JS_TEMPLATE + polyfills
  end

  private

  def self.gon_data
    Gon::Base.render_data(camel_case: true, init: true, need_tag: false)
  end

  def self.context_code(js_code)
    prelude + gon_data + js_code
  end

  def self.render_component_code(component_name, props)
    <<~JS
      var component = execJsGlobal.Components["#{component_name}"];
      var element = execJsGlobal.React.createElement(component, #{props.to_json});
      var html = execJsGlobal.ReactDOMServer.renderToString(element);
      return html;
    JS
  end

  def render_code(request, component_name, props)
    <<~JS
      (function() {
        #{self.class.gon_data}
        window.flashes = #{foundation_flashes(current_request: request).to_json};
        #{self.class.render_component_code(component_name, props)}
      })()
    JS
  end
end