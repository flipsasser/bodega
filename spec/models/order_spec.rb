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
  let(:order) { Bodega::Order.new }

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
    let(:cart) do
      {
        "TestProduct.1" => {
          product_type: "TestProduct",
          product_id: "1",
          quantity: "1"
        },
        "TestProduct.2" => {
          product_type: "TestProduct",
          product_id: "2",
          quantity: "2"
        }
      }
    end

    it "adds up the #order_products subtotals" do
      cart.each do |identifier, item|
        order.update_product(item)
      end
      order.save!
      order.subtotal.should == 80
    end
  end

  describe "cart management" do
    before { order.save! }

    it "defaults to quantity 1 when none given" do
      order.update_product(product_type: "TestProduct", product_id: 1)
      order.send(:order_product, "TestProduct.1").quantity.should == 1
    end

    it "accepts new quantities" do
      order.update_product(product_type: "TestProduct", product_id: 1, quantity: 10)
      order.send(:order_product, "TestProduct.1").quantity.should == 10
    end

    it "updates old quantities when no new quantity is given" do
      order.update_product(product_type: "TestProduct", product_id: 1, quantity: 10)
      order.update_product(product_type: "TestProduct", product_id: 1)
      order.send(:order_product, "TestProduct.1").quantity.should == 11
    end

    it "removes products when told to" do
      order.update_product(product_type: "TestProduct", product_id: 1, quantity: 10)
      order.update_product(product_type: "TestProduct", product_id: 1, quantity: 30, remove: "1")
      order.send(:order_product, "TestProduct.1").should be_nil
    end
  end
end
