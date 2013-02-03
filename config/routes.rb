Bodega::Engine.routes.draw do
  # Building orders
  get '', as: :new_order, to: 'orders#new'
  resource :order, only: :create, path: '' do
    # Add products to an order
    post :add, as: :add_to, to: 'orders#add'
    get 'remove/:product_id', as: :remove_from, constraints: {product_id: /.+\.\d+/}, to: 'orders#remove'

    # Processing orders
    get  :complete, to: 'orders#complete'
    post :complete, to: 'orders#complete'
  end

  # Existing orders
  get  ':id', as: :order, to: 'orders#show'
  post ':id', to: 'orders#update'
end
