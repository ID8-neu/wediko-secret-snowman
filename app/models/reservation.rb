class Reservation < ActiveRecord::Base
  belongs_to :gift_request
  belongs_to :donor

  scope :unreceived, -> { without_state(:received) }
  scope :received, -> { with_state(:received) }
  scope :reserved, -> { with_state(:reserved) }
  scope :notable, -> do
    joins(gift_request: {list: :event}).where("reservations.state <> 'received' OR events.end_date > ?", Date.today)
  end
  scope :delinquent, -> { where(delinquent: true) }

  state_machine :initial => :reserved do
    state :shipped do
      validates :shipment_method, presence: true
      validates :tracking_number, presence: true
    end
    after_transition any => :shipped do |reservation|
      reservation.send_purchased_email
      #send_ship_confirmation_email
    end
    after_transition any => :received do |reservation|
      reservation.thank_email_later
    end
    event :ship do
      transition :reserved => :shipped
    end

    event :receive do
      transition :shipped => :received
    end

    event :cancel do
      transition :shipped => :reserved
    end

    after_transition any => :reserved do |reservation, transition|
      reservation.update_attributes(tracking_number: nil, shipment_method: nil)
    end

    after_transition any => :received do |reservation, transition|
      reservation.update_attributes(delinquent: false)
    end
  end

  def status
    self.delinquent ? :delinquent : self.state
  end

  def send_purchased_email
     WishlistMailer.item_purchased_email(self.donor.user).deliver_now
  end
  def send_ship_confirmation_email(reservation)
     ShippingMailer.gift_shipped_email(Rails.configuration.x.wediko_notification_address).deliver_now
  end
  def thank_email_later
    ThankYouMailer.thank_you_email(self.donor.user).deliver_now
  end

end
