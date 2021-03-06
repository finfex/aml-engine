FactoryBot.define do
  factory(:aml_payment_card, class: AML::PaymentCard) do
    card_brand { 'VISA' }
    card_bin { '1234' }
    card_suffix { '5678' }
    association :aml_client, factory: :aml_client
    association :aml_payment_card_order, factory: :aml_payment_card_order
  end
end
