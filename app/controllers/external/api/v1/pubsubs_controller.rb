class External::Api::V1::PubsubsController < External::Api::V1::ApiV1Controller
  def generation
    return head :not_acceptable unless model.present?
    model.update! data.slice(:model_generation, :metrics).merge(last_trained: Time.now)
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
