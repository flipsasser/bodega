Bodega::Engine.routes.draw do
  # Building orders
  get '', as: :root, to: 'orders#new'
  post '', to: 'orders#create'

  # Add products to an order
  post :add, to: 'orders#add'

  # Processing orders
  get  :complete, to: 'orders#complete'
  post :complete, to: 'orders#complete'

  # Existing orders
  get  ':id', as: :order, to: 'orders#show'
  post ':id', to: 'orders#update'
end
