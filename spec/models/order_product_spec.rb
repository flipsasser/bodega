require 'spec_helper/active_record'
require 'bodega/order_product'

describe Bodega::OrderProduct do
  let(:product) { TestProduct.create!(product_attrs) }
  let(:product_attrs) { {} }
  let(:order_product) { Bodega::OrderProduct.new(product: product, quantity: 1) }

  describe "#identifier" do
    it "returns a friendly identifier" do
      order_product.identifier.should == "TestProduct.1"
    end
  end

  describe "#name" do
    it "defaults to a human-readable name" do
      order_product.name.should == "Test Product #1"
    end

    it "delegates to the product" do
      def product.name
        "Ohai"
      end
      order_product.name.should == "Ohai"
    end
  end

  describe "#quantity_and_name" do
    it "returns the quantity and the name" do
      order_product.quantity_and_name.should == "1 x Test Product #1"
    end
  end

  describe "#subtotal" do
    before { TestProduct.send :include, Bodega::Product }

    it "returns the subtotal for the product quantity" do
      order_product.subtotal.should == product.price
    end
  end
end
