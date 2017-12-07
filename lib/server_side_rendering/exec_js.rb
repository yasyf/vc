# this is heavily influenced by react-rails:
# https://github.com/reactjs/react-rails/blob/master/lib/react/server_rendering/exec_js_renderer.rb
class ServerSideRendering::ExecJs
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

  def initialize(js_code)
    @context = ExecJS.compile(self.class.prelude + gon_data + js_code)
  end

  def gon_data
    Gon::Base.render_data(camel_case: true, init: true, need_tag: false)
  end

  def render(request, component_name, props)
    js_code = <<~JS
      (function() {
        #{gon_data}
        window.flashes = #{foundation_flashes(current_request: request).to_json};
        var component = execJsGlobal.Components["#{component_name}"];
        var element = execJsGlobal.React.createElement(component, #{props.to_json});
        var html = execJsGlobal.ReactDOMServer.renderToString(element);
        return html;
      })()
    JS
    @context.eval(js_code).html_safe
  end

  private

  def compose_js(js)
    <<~JS
    (function() {
      var result = #{js};
      return result;
    })()
    JS
  end
end