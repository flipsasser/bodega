class Bodega::OrdersController < ApplicationController
  helper 'bodega/cart'
  include Bodega::PaymentMethod

  before_filter :find_order, only: [:show, :update]

  def add
    if product = params[:product]
      update_cart(product)
    end
    redirect_to root_path
  end

  def complete
    if current_order.finalize!(payment_method)
      current_products.clear
      redirect_to order_path(current_order)
    else
      flash[:error] = "There was a problem processing this order. Your account has not been charged."
      redirect_to new_order_path
    end
  end

  def create
    params[:products].each do |product|
      update_cart(product)
    end
    if params[:checkout]
      redirect_to payment_method.checkout_url(complete_url, root_url)
    else
      render :new
    end
  end

  def remove
    current_products.delete params[:product_id]
    redirect_to :back
  end

  protected
  def find_order
    raise ActiveRecord::RecordNotFound unless @order = Bodega::Order.where(identifier: params[:order_id] || params[:id]).first
  end

  def update_cart(product_hash)
    product_id = "#{product_hash[:type]}.#{product_hash[:id]}"
    if product_hash[:remove]
      current_products.delete product_id
    else
      if current_product = current_products[product_id]
        current_quantity = current_product[:quantity].to_i
      else
        current_quantity = 0
      end
      new_quantity = product_hash[:quantity] ? product_hash[:quantity].to_i : current_quantity + 1
      if product = product_hash[:type].constantize.where(id: product_hash[:id], keep_stock: true).first
        new_quantity = [product.number_in_stock, new_quantity].min
      end
      current_products[product_id] = product_hash.merge(quantity: new_quantity)
    end
  end
end
