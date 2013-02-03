require 'spec_helper'
require 'bodega/product'

describe Bodega::Product do
  let(:product) { TestProduct.create!(price: 25) }
  before do
    TestProduct.send :include, Bodega::Product
  end

  describe "#in_stock?" do
    it "returns true if the product is not stock-kept" do
      product.should be_in_stock
    end

    it "returns true if the number_in_stock is greater than zero" do
      product.keep_stock = true
      product.number_in_stock = 1
      product.save!
      product.should be_in_stock
    end

    it "returns false if the number_in_stock is less than zero" do
      product.keep_stock = true
      product.number_in_stock = 0
      product.save!
      product.should_not be_in_stock
    end
  end

  describe "#max_quantity" do
    it "returns the Bodega configuration value if the product is not stock-kept" do
      Bodega.stub(:config) { OpenStruct.new(max_quantity: 10) }
      product.max_quantity.should == Bodega.config.max_quantity
    end
  end

  describe ".for_sale" do
    it "returns products who are for sale today or don't have a start date" do
      product_1 = TestProduct.create!(for_sale_at: Date.today, price: 25.00)
      product_2 = TestProduct.create!(price: 30)
      non_product_1 = TestProduct.create!(for_sale_at: 1.day.from_now, price: 100)
      TestProduct.for_sale.should == [product_1, product_2]
    end

    it "returns products whose not_for_sale_at are past" do
      product_1 = TestProduct.create!(for_sale_at: Date.today, price: 25.00)
      product_2 = TestProduct.create!(price: 30)
      non_product_1 = TestProduct.create!(not_for_sale_at: 1.day.ago, price: 100)
      TestProduct.for_sale.should == [product_1, product_2]
    end

    it "returns products who don't have for_sale_at anything" do
      product_1 = TestProduct.create!(price: 25.00)
      product_2 = TestProduct.create!(price: 30)
      product_3 = TestProduct.create!(price: 100)
      TestProduct.for_sale.should == [product_1, product_2, product_3]
    end
  end

  describe ".popular" do
    it "returns products in order of sales from high to low" do
      require 'bodega/order_product'

      product_1 = TestProduct.create!(price: 25.00)
      3.times { Bodega::OrderProduct.create!(product: product_1, quantity: 5) }
      product_2 = TestProduct.create!(price: 30)
      5.times { Bodega::OrderProduct.create!(product: product_2, quantity: 5) }
      product_3 = TestProduct.create!(price: 100)
      4.times { Bodega::OrderProduct.create!(product: product_3, quantity: 5) }

      TestProduct.popular.should == [product_2, product_3, product_1]

      Bodega::OrderProduct.create!(product: product_1, quantity: 50)

      TestProduct.popular.should == [product_1, product_2, product_3]
    end
  end
end
