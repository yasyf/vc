module CompetitorLists::Base::ClassSetup
  def inherited(klass)
    @lists << klass
  end

  def init
    @lists = []
    Dir["#{File.dirname(__FILE__)}/../*.rb"].each do |file|
      require_dependency file
    end
  end

  def self.extended(base)
    base.init
  end

  def lists
    @lists
  end
end