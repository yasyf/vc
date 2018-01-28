class ServerSideRendering::Backends::MiniRacer < ServerSideRendering::Backends::Base
  def initialize(snapshot)
    @isolate = MiniRacer::Isolate.new(snapshot)
  end

  def render(request, component_name, props)
    context =  MiniRacer::Context.new(isolate: @isolate)
    result = context.eval(render_code(request, component_name, props)).html_safe
    context.dispose
    @isolate.idle_notification(100)
    result
  end

  def self.snapshot(js_code)
    MiniRacer::Snapshot.new(context_code(js_code)).tap do |snapshot|
      snapshot.warmup!(warmup_code)
    end
  end

  private

  def self.warmup_code
    <<~JS
      (function() {
        #{gon_data}
        window.flashes = [];
        #{render_component_code('Warmup', {})}
      })()
    JS
  end
end