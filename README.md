# Bodega

**Bodega is a lightweight Rails engine that allows any ActiveRecord::Base subclass to be purchased.** It lives seamlessly next to your Rails app, so installation and configuration is simple and fun.

## Installation
1. Add `gem 'bodega'` to your Gemfile and bundle
2. Run the install generator: `rails generator bodega:install`
3. Route to Bodega, like so:

	```ruby
	MyApp::Application.routes.draw do
	  mount Bodega::Engine => 'cart'
	end
	```
4. Profit (literally, for once)

## Configuration

Bodega configuration happens inside of `config/initializers/bodega.rb`. This file is created when you run the installation generator. Configuration is done via a block, like you're used to:

```ruby
Bodega.config do
  option_name :option_value
  boolean_option_name false
end
```

### Options

		</tr>
		<tr>
			<td>test_mode</td>
			<td>`true` in test or development modes; `false` otherwise</td>
			<td>Whether or not to process payments in test mode. Useful for development. You can override this if you need to but generally you won't need to.</td>
		</tr>
		<tr>
			<td>shipping_method</td>
			<td>:paypal</td>
			<td>The payment method used to process payments. Currently only Paypal and Stripe are supported.</td>
		</tr>
	</tbody>
</table>

#### Store Name

**Option**: `store_name`

**Default**: Bodega

**Description**: The name of your shop (passed to Stripe and PayPal). Override.

**Example**:

```
Bodega.config do
  store_name "Awesome Store"
end
```

#### Customer Method

**Option**: `customer_method`

**Default**: `:current_user`"

**Description**: The method on the controller used to associate a customer to an order. Set to `nil` if you don't want to associate customers to orders.

**Example**:

```
Bodega.config do
  customer_method :current_customer
end
```

#### Payment Method

**Option**: `payment_method`

**Default**: auto-detected

**Description**: The payment method used to process payments. Currently only Paypal and Stripe are supported. Bodega will auto-detect this if you have the Paypal or Stripe gems installed.

**Example**:

```
Bodega.config do
  payment_method :stripe
  stripe secret_key: "YOUR_STRIPE_SECRET_KEY", publishable_key: "YOUR_STRIPE_PUBLISHABLE_KEY"
end
```

#### Shipping Method

**Option**: `shipping_method`

**Default**: none

**Description**: The shipping method you use to ship your products. Install the `active_shipping` gem if you need this and then use the `shipping` configuration block.

**Example**:

```
Bodega.config do
  shipping_method :ups
  ups login: "UPS Login", password: "UPS Password", api_key: "UPS API Key"
  shipping do
  	units :imperial # Default is metric
  	origin do
  	  city "Baltimore"
  	  state "MD"
  	  postal_code "21231"
  	  country "US"
  	end
  end
  states "VA", "MD", "DE", "NJ" # States you ship to
end
```

#### Collecting Customer Emails



### Sample configuration

Here's an example of how you might configure Bodega:

```ruby
Bodega.config do
  # We don't associate orders to user / customer records
  customer_method nil
end

if Rails.env.production?
  Bodega.config do
    paypal(
      username: ENV['PAYPAL_USERNAME'],
      password: ENV['PAYPAL_PASSWORD'],
      signature: ENV['PAYPAL_SIGNATURE']
    )
  end
else
  Bodega.config do
    paypal(
      username: 'my_paypal_sandbox@username.com',
      password: 'paypal_sandbox_password',
      signature: 'SOME_SIGNATURE_I_GOT_FROM_PAYPAL'
    )
  end
end
```

## Making a model purchasable ("productizing")

Bodega just needs a few database columns and a mixin on a model to make it purchasable. You can do this to models you've already created in your app, or create new product models.

### Pre-existing models
For existing models, you need to run the "productize" generator:

1. `rails generate bodega:productize existing_class_name`
2. Add `include Bodega::Product` to your class definition, so something like this:
	```ruby
	class User < ActiveRecord::Base
	  include Bodega::Product
	  # etc …
	end
	```
3. `rake db:migrate`

### New models

Just generate new models using the "product" generator:

1. `rails generate bodega:product new_class_name`
2. `rake db:migrate`

## Adding an item to the cart

Once you've productized a model, it's trivial to create an "Add to Cart" button for it. Build your controllers and views the way you want, and when you're ready to make, say, a `Bucket` model purchasable, use the following helper method:

```ruby
<%= button_to_cart(@bucket) %>
```

As long as you've correctly productized using the instructions above, this will render a button that adds that instance of `Bucket` to the cart.

## Associating users to orders

Bodega will automatically attempt to use `current_user` as the `Bodega::Order#customer` association. If you use a different controller method for accessing the current user / customer / administrator / whatever, just provide it to the config block in your `config/initializers/bodega.rb`:

```ruby
Bodega.config do
  customer_method :this_method_returns_the_customer_on_all_controllers
end
```

If you don't want to associate a customer record, just set it to nil:

```ruby
Bodega.config do
  customer_method nil
end
```

## Customizing the cart appearance

The philosophy behind Bodega is that you decide on text, and we'll decide on markup. There are three ways to customize the cart's appearance.

### HTML & CSS

The cart uses the following markup:

```html
<table id="bodega-cart">
  <thead>
    <tr>
      <th class="product-name" colspan="2">Product</th>
      <th class="price">Price</th>
      <th class="total" colspan="2">Total</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class="quantity-field">
        <input class="quantity" id="products__quantity" max="7" min="1" name="products[][quantity]" type="number" value="1" />
      </td>
      <td class="product-name">
        {{Product Name}}
      </td>
      <td class="price">
        {{Product Price}}
      </td>
      <td class="subtotal">
        {{Total For Product}}
      </td>
      <td class="remove">
        <a href="#">Remove</a>
      </td>
    </tr>
  </tbody>
</table>
<button id="bodega-update" type="submit">Update Cart</button>
<button id="bodega-checkout" type="submit">Checkout</button>
```

This should create ample room for you to style the cart / checkout view as you see fit. Here's an example from [WomanNYC](http://www.womannyc.com/):

```css
#bodega-cart {
  border-collapse: collapse;
  border-width: 0;
  width: 100%;
}

#bodega-cart thead {
  border-bottom: 1px solid #ccc;
  text-align: left;
}

#bodega-cart td,
#bodega-cart th {
  font-size: 110%;
  padding: 0.2em 1em 0.2em 0;
}

#bodega-cart .product-name img {
  vertical-align: middle;
  width: 2em;
}

#bodega-cart .quantity-field {
  width: 3em;
}

#bodega-cart .quantity-field input {
  display: inline-block;
  font-size: 110%;
  width: 3em;
}
```

### I18N

Bodega allows you to customize the text labels for the "Product", "Price", and "Total" columns, the "Check Out", "Remove", and "Update Cart" button labels, and the empty cart notification text. Here's an example locale for configuring Bodega:

```yaml
en:
  bodega:
    product: "Bucket Name"
    price: "Bucket Price"
    total: "Total Price"
    check_out: "Check Out Now"
    remove: "Remove From Cart"
    update_cart: "Save Cart Changes"
    empty_cart: "You don't have any buckets in your cart yet!"
```

### Decorators

If your product instances respond to a method `Product#decorator`, which returns a decorator class, Bodega will automatically use that to present your product instead of the direct instance. It does this by following the convention of calling `DecoratorClass.decorate(instance)`. Given the following productized model:

```ruby
class Deck < ActiveRecord::Base
  include Bodega::Product

  def decorator
    Deckorator
  end
end
```

Bodega would use `Deckorator.decorate(@deck)` to use a decorator for the Deck instance. A common pattern in decorators is something like the following:

```ruby
class Deckorator
  attr_accessor :product

  class << self
    def decorate(products)
      if products.respond_to?(:each)
        products.map { |product| new(product) }
      else
        new(products)
      end
    end
  end

  def initialize(product)
    self.product = product
  end

  def name
    %[<img alt="#{product.name}" src="#{photo.url(:thumb)}" /> #{artist.name}: #{product.name}].html_safe
  end

  protected
  def method_missing(method, *args)
    product.send(method, *args)
  end
end

```

Use this to provide Bodega-specific labels for products which are being purchased.
