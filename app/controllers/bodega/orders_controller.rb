class Bodega::OrdersController < ApplicationController
  helper 'bodega/cart'

  before_filter :find_order, only: [:show, :update]

  def add
    if product = params[:product]
      update_cart(product)
    end
    redirect_to cart_path
  end

  def complete
    if current_order.finalize!(params)
      cart.clear
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
      return redirect_to current_order.payment_method.checkout_url(complete_url, cart_url)
    else
      if params[:calculate_shipping]
        session[:bodega_postal_code] = params[:postal_code]
        current_order.find_shipping_options!
      end
      render :new
    end
  end

  def remove
    cart.delete params[:product_id]
    redirect_to :back
  end

  protected
  def find_order
    raise ActiveRecord::RecordNotFound unless @order = Bodega::Order.where(identifier: params[:order_id] || params[:id]).first
  end

  def update_cart(product_hash)
    cart.update(product_hash)
  end
end
