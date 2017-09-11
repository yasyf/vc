class Average
  def initialize
    @avg = 0.0
    @n = 0
  end

  def add(i)
    @avg = (i + @n * @avg) / (@n + 1).to_f
    @n += 1
  end

  def to_i
    @avg
  end

  def to_f
    @avg.to_f
  end
end