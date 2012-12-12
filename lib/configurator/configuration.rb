require 'ostruct'

module Configurator
  class Configuration < OpenStruct
    def add_option(name, default, &block)
      defaults[name.to_sym] = default || block
    end

    def defaults
      @defaults ||= {}
    end

    def get(name)
      value = values[name] || defaults[name]
      if value.respond_to? :call
        value = self.instance_exec(self, &value)
      end
      value
    end

    def set(name, value, &block)
      values[name.to_sym] = block_given? ? block : value.freeze
    end

    def values
      @values ||= {}
    end

    private
    def method_missing(method, *args, &block)
      if defaults.key?(method.to_sym)
        if args.empty? && !block_given?
          get(method)
        else
          set(method, args.first, &block)
        end
      else
        super
      end
    end
  end
end
