class Bodega::OrdersController < ApplicationController
  helper 'bodega/cart'
  include Bodega::CartHelper
  #include Bodega::PaymentMethod::PayPal

  before_filter :find_order, only: [:show, :update]

  def add
    if product = params[:product]
      update_cart(product)
    end
    redirect_to root_path
  end

  def create
    params[:products].each do |product|
      update_cart(product)
    end
    if params[:checkout]
      redirect_to payment_provider_url
    else
      render :new
    end
  end

  protected
  def find_order
    raise ActiveRecord::NotFound unless @order = Bodega::Order.where(url: params[:order_id] || params[:id]).first
  end

  def payment_provider_url
    case Bodega.config.payment_method.to_sym
    when :paypal
      paypal_url
    else
      
    end
  end

  def update_cart(product)
    product_id = "#{product[:type]}.#{product[:id]}"
    if product[:remove]
      current_products.delete product_id
    else
      if current = current_products[product_id]
        current_quantity = current[:quantity].to_i
      else
        current_quantity = 0
      end
      new_quantity = product[:quantity] ? product[:quantity] : current_quantity + 1
      current_products[product_id] = product.merge(quantity: new_quantity)
    end
  end
end
