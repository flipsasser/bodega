require 'spec_helper'

describe Bodega do
  describe ".config" do
    describe "#payment_method" do
      it "auto-detects Paypal" do
        class Paypal; end
        Bodega.config.payment_method.should == :paypal
      end
    end

    describe "test_mode" do
      it "auto-detects test mode" do
        Bodega.config.test_mode.should be_true
      end
    end
  end
end
