#
# Cookbook Name:: blendtec
# Recipe:: credentials
#

node[:deploy].each do |app_name, deploy|
  Chef::Log.info("CakePHP deploy #{app_name} to #{deploy[:deploy_to]}/current/#{app_name}")

  app_dir = node[:config][:app_dir] rescue "app/"


  #generate core credentials file
  template "#{deploy[:deploy_to]}/current/#{app_dir}Config/credentials.php" do
    source 'credentials.php.erb'
    mode 0440
    group deploy[:group]

    if platform?('ubuntu')
      owner 'www-data'
    elsif platform?('amazon')
      owner 'apache'
    end

    variables(
        :cms_key => (node['config']['keys']['cms']['key'] rescue nil),
        :affirm_public_api_key => (node['config']['affirm']['publicAPIKey'] rescue nil),
        :affirm_private_api_key => (node['config']['affirm']['privateAPIKey'] rescue nil),
        :affirm_financial_product_key => (node['config']['affirm']['financialProductKey'] rescue nil),
        :avatax_account_number_test => (node['config']['avalar']['accountNumberTest'] rescue nil),
        :avatax_license_key_test => (node['config']['avalar']['licenseKeyTest'] rescue nil),
        :avatax_service_url_test => (node['config']['avalar']['serviceURLTest'] rescue nil),
        :avatax_account_number_live => (node['config']['avalar']['accountNumberLive'] rescue nil),
        :avatax_license_key_live => (node['config']['avalar']['licenseKeyLive'] rescue nil),
        :avatax_service_url_live => (node['config']['avalar']['serviceURLLive'] rescue nil),
        :suretax_testing_url => (node['config']['suretax']['testingUrl'] rescue nil),
        :suretax_validation_key_test => (node['config']['suretax']['validationKeyTest'] rescue nil),
        :suretax_client_number_test => (node['config']['suretax']['clientNumberTest'] rescue nil),
        :suretax_real_url => (node['config']['suretax']['realUrl'] rescue nil),
        :suretax_validation_key_real => (node['config']['suretax']['validationKeyReal'] rescue nil),
        :suretax_client_number_real => (node['config']['suretax']['clientNumberReal'] rescue nil),
        :email_parsing_username => (node['config']['emailParse']['username'] rescue nil),
        :email_parsing_password => (node['config']['emailParse']['password'] rescue nil),
        :email_parsing_connection_string => (node['config']['emailParse']['connection_string'] rescue nil),
        :email_parsing_backlog => (node['config']['emailParse']['backlog'] rescue nil),
        :strongview_username => (node['config']['strongview']['username'] rescue nil),
        :strongview_password => (node['config']['strongview']['password'] rescue nil),
        :strongview_organization => (node['config']['strongview']['organization'] rescue nil),
        :cms_secret1 => (node['config']['cms']['secret1'] rescue nil),
        :cms_secret2 => (node['config']['cms']['secret2'] rescue nil),
        :cms_secret3 => (node['config']['cms']['secret3'] rescue nil),
        :bazaarvoice_key => (node['config']['bazaarvoice']['cloud_key'] rescue nil),
        :usps_user_id => (node['config']['usps']['user_id'] rescue nil),
        :ups_license => (node['config']['ups']['license'] rescue nil),
        :ups_username => (node['config']['ups']['username'] rescue nil),
        :ups_password => (node['config']['ups']['password'] rescue nil),
        :mailchimp_key => (node['config']['mailchimp']['chimp_key'] rescue nil),
        :google_geokey => (node['config']['google']['geo_key'] rescue nil),
        :google_geo_testkey => (node['config']['google']['geo_test_key'] rescue nil),
        :auth_login => (node['config']['auth']['login'] rescue nil),
        :auth_test_login => (node['config']['auth']['test_login'] rescue nil),
        :auth_key => (node['config']['auth']['key'] rescue nil),
        :auth_test_key => (node['config']['auth']['test_key'] rescue nil
        :capcha_secret => (node['config']['keys']['captcha']['secret'] rescue nil,)
    )

    only_if do
      File.directory?("#{deploy[:deploy_to]}/current/#{app_dir}Config")
    end
  end

  #generate email config file
  template "#{deploy[:deploy_to]}/current/#{app_dir}Config/email.php" do
    source 'email.php.erb'
    mode 0440
    group deploy[:group]

    if platform?('ubuntu')
      owner 'www-data'
    elsif platform?('amazon')
      owner 'apache'
    end

    variables(
        :key => (node['config']['email']['ses_key'] rescue nil),
        :secret => (node['config']['email']['ses_secret'] rescue nil),
        :region => (node['config']['email']['ses_region'] rescue nil)
    )

    only_if do
      File.directory?("#{deploy[:deploy_to]}/current/#{app_dir}Config")
    end
  end

end
