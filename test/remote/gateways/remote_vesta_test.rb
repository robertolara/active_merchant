require 'test_helper'

class RemoteVestaTest < Test::Unit::TestCase
  def setup
    @gateway = VestaGateway.new(fixtures(:vesta))
   
    @amount = 100
    
    @credit_card = ActiveMerchant::Billing::CreditCard.new(
      number:             "4242424242424242",
      verification_value: "183",
      month:              "01",
      year:               "2018",
      first_name:         "Mario F.",
      last_name:          "Moreno Reyes"
    )
    #@declined_card = credit_card('4000300011112220')
    @options = {
      :device_fingerprint => "41l9l92hjco6cuekf0c7dq68v4",
      order_id: "345454tdf54hjj",
      description: 'Blue clip',
      billing_address: {
        address1: "Rio Missisipi #123",
        address2: "Paris",
        city: "Guerrero",
        country: "Mexico",
        zip: "5555",
        name: "Mario Reyes",
        phone: "12345678",
      }
    }
  end

  def test_successful_purchase
    response = @gateway.purchase(@amount, @credit_card, @options)
    assert_success response
    assert_equal nil, response.message
  end

  #def test_failed_purchase
  #  response = @gateway.purchase(@amount, @declined_card, @options)
  #  assert_failure response
  #  assert_equal 'REPLACE WITH FAILED PURCHASE MESSAGE', response.message
  #end

  #def test_successful_refund
  #  purchase = @gateway.purchase(@amount, @credit_card, @options)
  #  assert_success purchase

  #  assert refund = @gateway.refund(@amount, purchase.authorization)
  #  assert_success refund
  #  assert_equal 'REPLACE WITH SUCCESSFUL REFUND MESSAGE', refund.message
  #end

  def test_invalid_login
    gateway = VestaGateway.new(account_name: 'invalid', password: 'invalid')
    response = gateway.purchase(@amount, @credit_card, @options)
    
    assert_match "Login Failed", response.message
  end

  def test_transcript_scrubbing
    transcript = capture_transcript(@gateway) do
      @gateway.purchase(@amount, @credit_card, @options)
    end
    transcript = @gateway.scrub(transcript)
    assert_scrubbed(@credit_card.number, transcript)
    assert_scrubbed(@credit_card.verification_value, transcript)
  end

end
