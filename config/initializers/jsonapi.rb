module JSONAPI
  class LinkBuilder

    private

    def formatted_module_path_from_class(klass)
      scopes = module_scopes_from_class(klass)

      unless scopes.empty?
        scopes -= ['Internal']
        "/#{ scopes.map{ |scope| format_route(scope.to_s.underscore) }.join('/') }/"
      else
        "/"
      end
    end

  end
end
