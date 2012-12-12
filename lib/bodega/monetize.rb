module Bodega
  module Monetize
    def monetize(attribute)
      class_eval <<-monetize
        def #{attribute}=(value)
          self.#{attribute}_in_cents = (value.to_f * 100).to_i
        end

        def #{attribute}
          (#{attribute}_in_cents || 0) / 100.0
        end
      monetize
    end
  end
end
