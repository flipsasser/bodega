module Configurator
  autoload :Configuration, 'configurator/configuration'

  def self.extended(base)
    base.class_eval { remove_instance_variable(:@configuration) if defined? @configuration }
  end

  def config(&block)
    @configuration ||= Configuration.new
    if block_given?
      @configuration.instance_exec(@configuration, &block)
    end
    @configuration
  end

  private
  def option(name, default = nil, &block)
    config.add_option(name, default, &block)
  end

  def options(*names)
    names.each {|name| option(name) }
  end
end
