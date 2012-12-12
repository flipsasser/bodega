# Bodega

**Bodega allows any ActiveRecord::Base subclass to be purchased with a few simple steps:**

1. Install Bodega (add `gem 'bodega'` to your Gemfile and bundle)
2. For existing models:
	1. `rails g bodega:productize existing_class_name`
	2. Add `include Bodega::Product` to your class definition
3. For new models:
	1. `rails g bodega:product new_class_name`
4. Add `mount Bodega::Engine => 'cart'` to your `config/routes.rb` file
5. Profit (literally, for once)

## WIP

This is a work-in-progress and is currently only in use on [womannyc.com](http://www.womannyc.com). Play with it if you want. It's not that exciting; shut up.
