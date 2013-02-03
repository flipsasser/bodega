module Rails
  extend self

  def env
    OpenStruct.new(:development? => false, :test? => true)
  end
end
