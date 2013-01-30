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
    it "returns the subtotal for the product quantity" do
      product.stub(:price) { 25.0 }
      order_product.quantity = 2
      order_product.subtotal.should == 50.0
    end
  end

  describe "for stock-kept products" do
    before do
      product.stub(:price) { 25.0 }
      product.stub(:in_stock?) { true }
    end

    let(:product_attrs) { {keep_stock: true, number_in_stock: 1} }

    it "can't be saved if the product is out-of-stock" do
      product.stub(:in_stock?) { false }
      product.save!
      order_product.save
      order_product.errors[:quantity].size.should == 1
    end

    it "can't be saved if the quantity is too high" do
      order_product.quantity = 2
      order_product.save
      order_product.errors[:quantity].size.should == 1
    end

    it "reduces Product#number_in_stock when it's saved" do
      order_product.stub(:order) { OpenStruct.new }
      order_product.save!
      product.reload.number_in_stock.should == 0
    end
  end
end
