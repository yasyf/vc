module Component
  def hydrate(body, props = {}, options = {})
    tag = options.delete(:tag) || :div
    data = { data: {'react-class': @name, 'react-props': props.to_json } }

    content_tag(tag, body, options.deep_merge(data))
  end
end

Webpacker::React::Component.prepend Component