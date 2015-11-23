Rails.application.config.assets.precompile += %w( spree/checkout/payment/adyen.js )

# set the test mode on the adyen gem:
test_mode = Spree::Gateway::AdyenHPP.first.try { | adyenHPP | adyenHPP.preferences[:test_mode] }

# default should be :test (e.g. test_mode == true || test_mode.nil?)
Rails.application.config.adyen.environment = test_mode == false ? :live : :test
