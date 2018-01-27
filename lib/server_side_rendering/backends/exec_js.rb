class ServerSideRendering::Backends::ExecJs < ServerSideRendering::Backends::Base
  def initialize(js_code)
    @context = ExecJS.compile(self.class.context_code(js_code))
  end

  def render(request, component_name, props)
    @context.eval(render_code(request, component_name, props)).html_safe
  end
end