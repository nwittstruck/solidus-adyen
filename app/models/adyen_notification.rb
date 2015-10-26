# The +AdyenNotification+ class handles notifications sent by Adyen to your servers.
#
# Because notifications contain important payment status information, you should store
# these notifications in your database. For this reason, +AdyenNotification+ inherits
# from +ActiveRecord::Base+, and a migration is included to simply create a suitable table
# to store the notifications in.
#
# Adyen can either send notifications to you via HTTP POST requests, or SOAP requests.
# Because SOAP is not really well supported in Rails and setting up a SOAP server is
# not trivial, only handling HTTP POST notifications is currently supported.
#
# @example
#    @notification = AdyenNotification.log(request)
#    if @notification.successful_authorisation?
#      @invoice = Invoice.find(@notification.merchant_reference)
#      @invoice.set_paid!
#    end
class AdyenNotification < ActiveRecord::Base
  AUTO_CAPTURE_ONLY_METHODS = ["ideal", "c_cash", "directEbanking"].freeze

  AUTHORISATION = "AUTHORISATION".freeze
  CANCELLATION = "CANCELLATION".freeze
  REFUND = "REFUND".freeze
  CANCEL_OR_REFUND = "CANCEL_OR_REFUND".freeze
  CAPTURE = "CAPTURE".freeze
  CAPTURE_FAILED = "CAPTURE_FAILED".freeze
  REFUND_FAILED = "REFUND_FAILED".freeze
  REFUNDED_REVERSED = "REFUNDED_REVERSED".freeze

  belongs_to :prev,
    class_name: self,
    foreign_key: :original_reference,
    primary_key: :psp_reference,
    inverse_of: :next

  # Auth will have no original reference, all successive notifications with
  # reference the first auth notification
  has_many :next,
    class_name: self,
    foreign_key: :original_reference,
    primary_key: :psp_reference,
    inverse_of: :prev

  belongs_to :order,
    class_name: Spree::Order,
    primary_key: :number,
    foreign_key: :merchant_reference

  scope :processed, -> { where processed: true }

  scope :authorisation, -> { where event_code: "AUTHORISATION" }

  # A notification should always include an event_code
  validates_presence_of :event_code

  # A notification should always include a psp_reference
  validates_presence_of :psp_reference

  # Make sure we don't end up with an original_reference with an empty string
  before_validation { |notification| notification.original_reference = nil if notification.original_reference.blank? }

  # Logs an incoming notification into the database.
  #
  # @param [Hash] params The notification parameters that should be stored in the database.
  # @return [Adyen::Notification] The initiated and persisted notification instance.
  # @raise This method will raise an exception if the notification cannot be stored.
  # @see Adyen::Notification::HttpPost.log
  def self.build(params)
    converted_params = {}

    # Assign explicit each attribute from CamelCase notation to notification
    # For example, merchantReference will be converted to merchant_reference
    self.new.tap do |notification|
      params.each do |key, value|
        setter = "#{key.to_s.underscore}="
        notification.send(setter, value) if notification.respond_to?(setter)
      end
    end
  end

  def payment
    Spree::Payment.find_by response_code: original_reference || psp_reference
  end

  # Returns true if this notification is an AUTHORISATION notification
  # @return [true, false] true iff event_code == 'AUTHORISATION'
  # @see Adyen.notification#successful_authorisation?
  def authorisation?
    event_code == 'AUTHORISATION'
  end

  def capture?
    event_code == 'CAPTURE'
  end

  def actions
    self.operations.
      split(",").
      map(&:downcase)
  end

  # https://docs.adyen.com/display/TD/Notification+fields
  def modification_event?
    [ CANCELLATION,
      REFUND,
      CANCEL_OR_REFUND,
      CAPTURE,
      CAPTURE_FAILED,
      REFUND_FAILED,
      REFUNDED_REVERSED
    ].member? self.event_code
  end

  def normal_event?
    AUTHORISATION == self.event_code
  end

  def bank_transfer?
    self.payment_method.match(/^bankTransfer/)
  end

  def auto_captured?
    payment_method_auto_capture_only? || bank_transfer?
  end

  def payment_method_auto_capture_only?
    AUTO_CAPTURE_ONLY_METHODS.member?(self.payment_method)
  end

  alias_method :authorization?, :authorisation?
end
