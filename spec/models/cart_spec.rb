require 'spec_helper/active_record'
require 'bodega/cart'

describe Bodega::Cart do
  let(:cart) { Bodega::Cart.new({}) }

  it "defaults to quantity 1 when none given" do
    cart.update(type: "TestProduct", id: 1)
    cart["TestProduct.1"][:quantity].should == 1
  end

  it "accepts new quantities" do
    cart.update(type: "TestProduct", id: 1, quantity: 10)
    cart["TestProduct.1"][:quantity].should == 10
  end

  it "updates old quantities when no new quantity is given" do
    cart.update(type: "TestProduct", id: 1, quantity: 10)
    cart.update(type: "TestProduct", id: 1)
    cart["TestProduct.1"][:quantity].should == 11
  end

  it "removes products when told to" do
    cart.update(type: "TestProduct", id: 1, quantity: 10)
    cart.update(type: "TestProduct", id: 1, quantity: 30, remove: "1")
    cart["TestProduct.1"].should be_nil
  end
end
