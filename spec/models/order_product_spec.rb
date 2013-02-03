require 'spec_helper'
require 'bodega/order_product'

describe Bodega::OrderProduct do
  let(:product) { TestProduct.create!(product_attrs) }
  let(:product_attrs) { {price: 49.95} }
  let(:order_product) { described_class.new(product: product, quantity: 1) }

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
    let(:product_attrs) { {price: 49.95, keep_stock: true, number_in_stock: 1} }

    it "can't be saved if the product is out-of-stock" do
      product.stub(:in_stock?) { false }
      product.save!
      order_product.save
      order_product.errors[:quantity].first.should == "Sorry, this product is sold out."
    end

    it "notifies me if my quantity is higher than the number left" do
      order_product.quantity = 2
      order_product.save
      order_product.errors[:quantity].first.should == "There is only one in stock!"
    end

    it "can't be saved if the quantity is too high" do
      product.stub(:number_in_stock) { 2 }
      order_product.quantity = 3
      order_product.save
      order_product.errors[:quantity].first.should == "There are only 2 in stock!"
    end

    it "reduces Product#number_in_stock when #update_stock is called" do
      order_product.stub(:order) { OpenStruct.new }
      order_product.save!
      order_product.update_stock
      product.reload.number_in_stock.should == 0
    end
  end
end
