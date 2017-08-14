class PaypalService
  def initialize(params)
    @transaction = params[:transaction]
    @return_url = params[:return_url]
    @cancel_url = params[:cancel_url]
    @money = params[:money]
    @currency = @transaction.currency
  end
 
  def create_instant_payment
    payment = PayPal::SDK::REST::Payment.new({
      intent: "sale",
      payer: { payment_method: "paypal" },
      redirect_urls: { return_url: @return_url, cancel_url: @cancel_url },
      transactions: [{ item_list: { items: get_item_list },
        amount: { total: number_with_precision(@money, precision: 2),
        currency: @currency }
      }]
    })
    payment.create
    payment
  end

  def self.execute_payment(payment_id, payer_id)
    payment = PayPal::SDK::REST::Payment.find(payment_id)
    payment.execute(payer_id: payer_id) unless payment.error
    payment
  end

  #  def self.refund_payment(payment_no)
  #     payment = PayPal::SDK::REST::Payment.find(payment_no)
  #     # Retrieve sale object's id (Have to refund the transaction with this)
  #     sale = payment.transactions[0].related_resources[0].sale
  #     # The code here is to refund the full amount,
  #     # read more about refund part of the total amount
  #     refund = sale.refund({ amount: { total: sale.amount.total,
  #     currency: sale.amount.currency }})
  # end
 
private
  # PayPal will also check all the currencies and subtotals
  # whether are match to the currency and total amount in payment object.
  # It's not a required field, but it's better to show all details
  # for your buyers when getting their approval.
  def get_item_list
    arr = []
    @transaction.items.each do |item|
      # activate this later
      # arr << { name: item.name, price: item.price, currency: item: currency, quantity: item.quantity }
    end
  end
end