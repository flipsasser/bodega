class Bodega::OrdersController < ApplicationController
  before_filter :find_order, only: %w(show)

  helper 'bodega/cart'

  def add
    if product = params[:order_product]
      update_cart(product)
    end
    redirect_to new_order_path
  end

  def complete
    if current_order.finalize!(params)
      session.delete(:bodega_order_id)
      redirect_to order_path(current_order), notice: t('bodega.order_processed')
    else
      redirect_to new_order_path, error: t('bodega.order_failed')
    end
  end

  def create
    if current_order.update_attributes(params[:order].merge(checking_out: params[:checkout].present?))
      if !current_order.new_shipping_rates? && params[:checkout]
        redirect_to current_order.payment_method.checkout_url(complete_order_url, new_order_url, params)
      else
        redirect_to new_order_path
      end
    else
      render :new
    end
  end

  def remove
    current_order.remove_product params[:product_id]
    redirect_to :back
  end

  def show
    render :edit unless @order.complete?
  end

  protected
  def find_order
    raise ActiveRecord::RecordNotFound unless @order = Bodega::Order.where(identifier: params[:order_id] || params[:id]).first
  end

  def update_cart(product_hash)
    if current_order.update_product(product_hash)
      session[:bodega_order_id] = current_order.identifier
    end
  end
end
