module Spree
  Order.class_eval do

    scope :abandoned,
      -> { limit_time = Time.current - SpreeAbandonedCarts::Config.abandoned_after_minutes.minutes

           incomplete.
           where('email IS NOT NULL').
           where("#{quoted_table_name}.item_total > 0").
           where("#{quoted_table_name}.updated_at < ?", limit_time) }

    scope :abandon_not_notified,
      -> { abandoned.
           where("#{quoted_table_name}.created_at > ?", 2.days.ago).
           where(abandoned_cart_email_sent_at: nil) }

    def abandoned_cart_actions
      AbandonedCartMailer.abandoned_cart_email(self).deliver_now
      touch(:abandoned_cart_email_sent_at)
    end

    def last_for_user?
      Order.where(email: email).where('id > ?', id).none?
    end

  end
end
