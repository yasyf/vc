class ServerSideRendering::Render
  RENDERER_ENTRY_POINT = 'server_side_render.js'

  def self.renderer
    @renderer ||= begin
      server_pack = WebpackerManifestContainer.new.find_asset(RENDERER_ENTRY_POINT)
      ExecJs.new(server_pack)
    end
  end

  def self.render(component_name, props)
    renderer.render component_name, props
  end
end
