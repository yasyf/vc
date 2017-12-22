module External::Concerns
  module Reactable
    extend ActiveSupport::Concern
    include External::ReactServerHelper

    private

    def title(title)
      @title = title
    end

    def description(description)
      @description = description
    end

    def component(name)
      @component_name = name
    end

    def props(props)
      @component_props ||= {}
      @component_props.merge!(props.keep_if { |k, v| !v.nil? })
    end
  end
end
