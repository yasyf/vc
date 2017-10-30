class ServerSideRendering::Render
  RENDERER_ENTRY_POINT = 'external/server_side_render.js'

  def self.renderer
    @renderer ||= begin
      server_pack = ServerSideRendering::WebpackerManifestContainer.new.find_asset(RENDERER_ENTRY_POINT)
      ServerSideRendering::ExecJs.new(server_pack)
    end
  end

  def self.render(component_name, props)
    renderer.render component_name, props
  end
end
