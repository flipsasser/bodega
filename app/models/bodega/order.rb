require 'maintain'

module Bodega
  class Order < ActiveRecord::Base
    self.table_name = :bodega_orders

    attr_accessor :checking_out

    attr_accessible :email, :checking_out
    attr_accessible :order_products_attributes, :postal_code, :shipping_rate_code
    attr_accessible :street_1, :street_2, :city, :state

    before_create :set_identifier
    before_save :set_shipping_rates, if: :set_shipping_rates?
    before_save :calculate_shipping, if: :shipping_rate_code_changed?
    before_save :set_total

    belongs_to :customer, polymorphic: true

    has_many :order_products, class_name: 'Bodega::OrderProduct', dependent: :destroy
    accepts_nested_attributes_for :order_products

    delegate :count, :empty?, :size, to: :order_products

    maintain :status do
      state :new, 1, default: true
      state :complete, 2
      on :enter, :complete, :mark_order_products_as_purchased
    end

    monetize :shipping_cents
    monetize :tax_cents
    monetize :total_cents

    serialize :shipping_rates

    validates_presence_of :email, if: :require_email?

    def finalize!(options)
      self.class.transaction do
        self.status = :complete
        self.save!
        begin
          self.payment_id = payment_method.complete!(options)
          self.save!
        rescue Exception
          raise ActiveRecord::Rollback
        end
      end
    end

    def new_shipping_rates?
      @new_shipping_rates
    end

    def payment_method
      return nil unless Bodega.config.payment_method
      @payment_method ||= "Bodega::PaymentMethod::#{Bodega.config.payment_method.to_s.camelize}".constantize.new(self)
    end

    def products
      order_products.map(&:product)
    end

    def ready?
      shipping_method.nil? || shipping_rates.present?
    end

    def remove_product(item)
      unless item.is_a?(Bodega::OrderProduct)
        item = order_product(item)
      end
      item.destroy
      order_products.delete(item)
    end

    def shipping_method
      case Bodega.config.shipping_method
      when :ups
        Bodega::ShippingMethod::UPS.new(self)
      end
    end

    def shipping_rate_options
      @shipping_rate_options ||= ActiveSupport::OrderedHash.new.tap do |rates|
        shipping_rates.sort_by {|code, rate| rate[:price] }.each do |code, rate|
          name = rate[:name]
          price = Money.new(rate[:price])
          rates["#{name}: #{price.format}"] = code
        end
      end
    end

    def state_options
      US_STATES.values
    end

    def subtotal
      order_products.inject(Money.new(0)) {|sum, order_product| sum += order_product.subtotal }
    end

    def summary
      order_products.map(&:quantity_and_name).to_sentence
    end

    def to_param
      identifier
    end

    def update_product(item)
      if order_product = order_product(item)
        if item[:remove]
          remove_product(order_product)
        else
          current_quantity = order_product.quantity
          new_quantity = item[:quantity] ? item[:quantity].to_i : current_quantity + 1
          order_product.update_attributes(quantity: new_quantity)
        end
      else
        order_product = order_products.build({quantity: 1}.merge(item))
      end
      save unless empty?
    end

    protected
    def calculate_shipping
      if shipping_rate_code
        self.shipping_rate_name = shipping_rates[shipping_rate_code][:name]
        self.shipping = shipping_rates[shipping_rate_code][:price] / 100.0
      else
        self.shipping = 0
      end
    end

    def calculate_tax
      self.tax = 0
    end

    def mark_order_products_as_purchased
      order_products.each(&:update_stock)
    end

    def order_product(item)
      if item.is_a?(Hash)
        order_products.detect {|order_product| order_product.product_type == item[:product_type] && order_product.product_id == item[:product_id].to_i }
      else
        order_products.detect {|order_product| order_product.identifier == item }
      end
    end

    def require_email?
      Bodega.config.collect_email && persisted? && (postal_code_changed? || checking_out)
    end

    def set_identifier
      self.identifier = self.class.count.succ.to_s(36)
    end

    def set_shipping_rates
      if postal_code.present?
        self.shipping_rates = shipping_method.rates
        self.shipping_rate_code = shipping_rate_options.values.first
        calculate_shipping
      else
        self.shipping_rates = self.shipping_rate_code = nil
      end
      @new_shipping_rates = true
    end

    def set_shipping_rates?
      postal_code_changed? || order_products.any?(&:quantity_changed?)
    end

    def set_total
      self.total = subtotal + tax + shipping
    end
  end


  US_STATES = ActiveSupport::OrderedHash.new
  Hash['Alabama', 'AL',
    'Alaska', 'AK',
    'Arizona', 'AZ',
    'Arkansas', 'AR',
    'California', 'CA',
    'Colorado', 'CO',
    'Connecticut', 'CT',
    'Delaware', 'DE',
    'District Of Columbia', 'DC',
    'Florida', 'FL',
    'Georgia', 'GA',
    'Hawaii', 'HI',
    'Idaho', 'ID',
    'Illinois', 'IL',
    'Indiana', 'IN',
    'Iowa', 'IA',
    'Kansas', 'KS',
    'Kentucky', 'KY',
    'Louisiana', 'LA',
    'Maine', 'ME',
    'Maryland', 'MD',
    'Massachusetts', 'MA',
    'Michigan', 'MI',
    'Minnesota', 'MN',
    'Mississippi', 'MS',
    'Missouri', 'MO',
    'Montana', 'MT',
    'Nebraska', 'NE',
    'Nevada', 'NV',
    'New Hampshire', 'NH',
    'New Jersey', 'NJ',
    'New Mexico', 'NM',
    'New York', 'NY',
    'North Carolina', 'NC',
    'North Dakota', 'ND',
    'Ohio', 'OH',
    'Oklahoma', 'OK',
    'Oregon', 'OR',
    'Pennsylvania', 'PA',
    'Rhode Island', 'RI',
    'South Carolina', 'SC',
    'South Dakota', 'SD',
    'Tennessee', 'TN',
    'Texas', 'TX',
    'Utah', 'UT',
    'Vermont', 'VT',
    'Virginia', 'VA',
    'Washington', 'WA',
    'West Virginia', 'WV',
    'Wisconsin', 'WI',
    'Wyoming', 'WY'
  ].sort.each do |key, value|
    US_STATES[key] = value
  end
end
