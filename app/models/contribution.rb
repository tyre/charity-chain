class Contribution < ActiveRecord::Base
  include TokenHelper
  
  attr_accessible :payment, :goal, :amount_per_check_in_cents, :email, :name, :token
  
  belongs_to :goal
  has_one :payment
  
  after_create :set_token
  delegate :amount, to: :payment
  
  def to_param
    token
  end
  
  def self.process(goal, params)
    params[:transaction_description] = "Contribution to Goal ##{goal.id} by #{params[:cardholder_name]}"
    payment = Payment.process(params)
    contribution = create_contribution(goal, payment, params)
    payment.update_attribute(:contribution, contribution)
    goal.add_to_reserve_amount(payment.amount)
    contribution
  end

  def self.create_contribution(goal, payment, params)
    Contribution.create(goal: goal, payment: payment, name: params[:cardholder_name])
  end
  
  private
  
  def set_token
    update_attribute(:token, create_token)
  end
end