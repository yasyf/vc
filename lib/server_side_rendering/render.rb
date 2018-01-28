class ServerSideRendering::Render
  RENDERER_ENTRY_POINT = 'external/server_side_render.js'

  # Worker level
  def self.snapshot
    @snapshot ||= begin
      server_pack = ServerSideRendering::WebpackerManifestContainer.new.find_asset(RENDERER_ENTRY_POINT)
      ServerSideRendering::Backends::MiniRacer.snapshot(server_pack)
    end
  end

  # Thread level
  def self.renderer
    @renderer ||= ServerSideRendering::Backends::MiniRacer.new(snapshot)
  end

  # Request level
  def self.render(request, component_name, props)
    renderer.render request, component_name, props
  end
end
