class External::Api::V1::PubsubsController < External::Api::V1::ApiV1Controller
  def generation
    return head :not_acceptable unless model.present?
    metrics = data[:metrics].transform_values(&:to_f)
    model.update! model_generation: data[:model_generation], last_trained: Time.now
    head :ok
  end

  private

  def model
    @model ||= Model.find(data[:id])
  end

  def data
    @data ||= JSON.parse(Base64.decode64(generation_params[:data])).with_indifferent_access
  end

  def generation_params
    params.require(:message).permit(:data)
  end
end
