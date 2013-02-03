require 'spec_helper'
require 'bodega/order'
require 'bodega/order_product'
require 'bodega/product'

describe Bodega::Order do
  before do
    TestProduct.send :include, Bodega::Product
  end

  let!(:product_1) { TestProduct.create!(price: 30) }
  let!(:product_2) { TestProduct.create!(price: 25) }
  let(:cart) do
    {
      "TestProduct.1" => {
        type: "TestProduct",
        id: "1",
        quantity: "1"
      },
      "TestProduct.2" => {
        type: "TestProduct",
        id: "2",
        quantity: "2"
      }
    }
  end
  let(:order) { Bodega::Order.new }

  describe "#build_products" do
    it "builds an order from a cart" do
      order.build_products(cart)
      order.order_products.size.should == 2
    end
  end

  describe "#payment_method" do
    require 'bodega'
    require 'bodega/payment_method'
    class Paypal; end

    it "returns an instance of Bodega::PaymentMethod::Base" do
      order.payment_method.should be_instance_of(Bodega::PaymentMethod::Paypal)
    end

    it "returns an instance of Bodega::PaymentMethod::Base with a reference to the order" do
      order.payment_method.order.should == order
    end
  end

  describe "#shipping_method" do
    require 'bodega'
    require 'bodega/shipping_method'

    before do
      Bodega.config { shipping_method :ups }
      module ActiveMerchant; module Shipping; class UPS; end; end; end
    end

    it "returns an instance of Bodega::ShippingMethod::Base" do
      order.shipping_method.should be_instance_of(Bodega::ShippingMethod::UPS)
    end
  end

  describe "#subtotal" do
    it "adds up the #order_products subtotals" do
      order.build_products(cart)
      order.save!
      order.subtotal.should == 80
    end
  end
end
