module Bodega
  class Order < ActiveRecord::Base
    before_save :set_total
    before_create :set_identifier

    belongs_to :customer, polymorphic: true
    has_many :order_products, class_name: 'Bodega::OrderProduct', dependent: :destroy
    has_many :products, through: :order_products

    monetize :tax_cents
    monetize :total_cents

    def finalize!(payment_method)
      self.class.transaction do
        self.save!
        begin
          self.payment_id = payment_method.complete!
          self.save!
        rescue Exception => e
          raise ActiveRecord::Rollback
          raise e.inspect
        end
      end
    end

    def subtotal
      @subtotal ||= order_products.inject(Money.new(0)) {|sum, order_product| sum += order_product.subtotal }
    end

    def set_total
      self.total = subtotal + tax
    end

    def to_param
      identifier
    end

    protected
    def set_identifier
      self.identifier = self.class.count.succ.to_s(36)
    end
  end
end
