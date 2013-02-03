# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "bodega"
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Flip Sasser"]
  s.date = "2013-02-03"
  s.description = "Bodega adds checkout logic to any model in your app!"
  s.email = "flip@x451.com"
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".rspec",
    ".rvmrc",
    "Gemfile",
    "Gemfile.lock",
    "MIT-LICENSE",
    "README.md",
    "Rakefile",
    "VERSION",
    "app/assets/images/bodega/.gitkeep",
    "app/assets/javascripts/bodega/application.js",
    "app/assets/stylesheets/bodega/application.css",
    "app/controllers/bodega/orders_controller.rb",
    "app/helpers/bodega/application_helper.rb",
    "app/helpers/bodega/cart_helper.rb",
    "app/models/bodega/cart.rb",
    "app/models/bodega/order.rb",
    "app/models/bodega/order_product.rb",
    "app/models/bodega/product.rb",
    "app/views/bodega/orders/new.html.erb",
    "app/views/bodega/orders/show.html.erb",
    "bodega.gemspec",
    "config/locales/en.yml",
    "config/routes.rb",
    "db/migrate/20121111170337_create_bodega_orders.rb",
    "db/migrate/20121111170420_create_bodega_order_products.rb",
    "lib/bodega.rb",
    "lib/bodega/engine.rb",
    "lib/bodega/payment_method.rb",
    "lib/bodega/payment_method/base.rb",
    "lib/bodega/payment_method/paypal.rb",
    "lib/bodega/shipping_method.rb",
    "lib/bodega/shipping_method/base.rb",
    "lib/bodega/shipping_method/ups.rb",
    "lib/bodega/version.rb",
    "lib/generators/bodega/install/install_generator.rb",
    "lib/generators/bodega/product/USAGE",
    "lib/generators/bodega/product/product_generator.rb",
    "lib/generators/bodega/product/templates/migration.rb",
    "lib/generators/bodega/product/templates/model.rb",
    "lib/generators/bodega/productize/USAGE",
    "lib/generators/bodega/productize/productize_generator.rb",
    "lib/generators/bodega/productize/templates/migration.rb",
    "lib/tasks/bodega_tasks.rake",
    "script/rails",
    "spec/lib/bodega/payment_method/base_spec.rb",
    "spec/lib/bodega_spec.rb",
    "spec/models/cart_spec.rb",
    "spec/models/order_product_spec.rb",
    "spec/models/order_spec.rb",
    "spec/models/product_spec.rb",
    "spec/spec_helper.rb",
    "spec/spec_helper/active_record.rb"
  ]
  s.homepage = "http://github.com/flipsasser/bodega"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Bodega adds checkout logic to any model in your app!"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 3.2.11"])
      s.add_runtime_dependency(%q<configurator2>, [">= 0.1.3"])
      s.add_runtime_dependency(%q<i18n>, [">= 0"])
      s.add_runtime_dependency(%q<money-rails>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, [">= 3.2.11"])
      s.add_dependency(%q<configurator2>, [">= 0.1.3"])
      s.add_dependency(%q<i18n>, [">= 0"])
      s.add_dependency(%q<money-rails>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 3.2.11"])
    s.add_dependency(%q<configurator2>, [">= 0.1.3"])
    s.add_dependency(%q<i18n>, [">= 0"])
    s.add_dependency(%q<money-rails>, [">= 0"])
  end
end

