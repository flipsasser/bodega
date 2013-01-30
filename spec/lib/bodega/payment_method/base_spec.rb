require 'bodega'
require 'bodega/payment_method/base'
require 'active_support/core_ext/string/inflections'

describe Bodega::PaymentMethod::Base do
  describe ".options" do
    it "defines options on the Bodega configuration instance" do
      described_class.options(:a, :b, :z)
      Bodega.config.base.should_not be_nil
    end
  end
end
