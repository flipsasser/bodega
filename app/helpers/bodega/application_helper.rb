module Bodega
  module ApplicationHelper
    def self.included(base)
      base.class_eval do
        alias :method_missing_without_bodega :method_missing
        alias :method_missing :method_missing_with_bodega
      end
    end
    protected
    def method_missing_with_bodega(method_name, *args)
      if method_name.to_s =~ /.+_(url|path)$/ && main_app.respond_to?(method_name)
        return main_app.send(method_name, *args)
      end
      method_missing_without_bodega method_name, *args
    end
  end
end
