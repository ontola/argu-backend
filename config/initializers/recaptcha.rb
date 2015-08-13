#https://github.com/ambethia/recaptcha/

Recaptcha.configure do |config|
  config.public_key  = '6LcHLgsTAAAAAIpL33b3xrh05nzIiqMgpCXL3ODY'
  config.private_key = '6LcHLgsTAAAAABZJNUY3v8OaXBcjDXRIk1nSW3DZ'
  # Uncomment the following line if you are using a proxy server:
  # config.proxy = 'http://myproxy.com.au:8080'
  # Uncomment if you want to use the newer version of the API,
  # only works for versions >= 0.3.7:
  # config.api_version = 'v2'
end