module NilObjectHelpers
  def present?
    false
  end

  def blank?
    true
  end

  def nil?
    true
  end
end

Dalli::Server::NilObject.prepend NilObjectHelpers