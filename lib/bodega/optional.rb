module Bodega
  module Optional
    def options(*new_options)
      option_namespace = self.name.split('::').pop.underscore
      Bodega.class_eval do
        option option_namespace do
          options(*new_options.flatten)
        end
      end
    end
  end
end
