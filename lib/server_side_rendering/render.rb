class ServerSideRendering::Render
  RENDERER_ENTRY_POINT = 'external/server_side_render.js'
  POOL_SIZE = 2

  # Worker level
  def self.snapshot
    @snapshot ||= begin
      server_pack = ServerSideRendering::WebpackerManifestContainer.new.find_asset(RENDERER_ENTRY_POINT)
      ServerSideRendering::Backends::MiniRacer.snapshot(server_pack)
    end
  end

  def self.renderer_pool
    @renderer_pool ||= (0...POOL_SIZE).map { ServerSideRendering::Backends::MiniRacer.new(snapshot) }
  end

  # Thread level, try sharing context?
  def self.renderer
    renderer_pool.sample
  end

  # Request level
  def self.render(request, component_name, props)
    renderer.render request, component_name, props
  end
end
