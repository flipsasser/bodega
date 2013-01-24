Bodega::Engine.routes.draw do
  # Building orders
  get '', as: :cart, to: 'orders#new'
  post '', to: 'orders#create'

  # Add products to an order
  post :add, to: 'orders#add'
  get 'remove/:product_id', as: :remove, constraints: {product_id: /.+\.\d+/}, to: 'orders#remove'

  # Processing orders
  get  :complete, to: 'orders#complete'
  post :complete, to: 'orders#complete'

  # Existing orders
  get  ':id', as: :order, to: 'orders#show'
  post ':id', to: 'orders#update'
end
