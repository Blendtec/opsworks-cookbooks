#
# Cookbook Name:: cakephp
# Recipe:: deploy
#

include_recipe "composer::install"

node[:deploy].each do |app_name, deploy|
  Chef::Log.info("CakePHP deploy #{app_name} to #{deploy[:deploy_to]}/current/#{app_name}")

  app_dir = node[:config][:app_dir] rescue "app/"

  #generate database config file
  template "#{deploy[:deploy_to]}/current/#{app_dir}Config/database.php" do
    source 'database.php.erb'
    mode 0440
    group deploy[:group]

    if platform?('ubuntu')
      owner 'www-data'
    elsif platform?('amazon')
      owner 'apache'
    end

    variables(
        :host =>     (deploy[:database][:host] rescue nil),
        :user =>     (deploy[:database][:username] rescue nil),
        :password => (deploy[:database][:password] rescue nil),
        :db =>       (deploy[:database][:database] rescue nil),
        :emailParseDataSource => (deploy[:emailParsing][:datasource] rescue nil),
        :emailParseServer =>     (deploy[:emailParsing][:server] rescue nil),
        :emailParseUser =>       (deploy[:emailParsing][:username] rescue nil),
        :emailParsePassword =>   (deploy[:emailParsing][:password] rescue nil)
    )

    only_if do
      File.directory?("#{deploy[:deploy_to]}/current/#{app_dir}Config")
    end
  end

  #generate core config file
  template "#{deploy[:deploy_to]}/current/#{app_dir}Config/core.php" do
    source 'core.php.erb'
    mode 0440
    group deploy[:group]

    if platform?('ubuntu')
      owner 'www-data'
    elsif platform?('amazon')
      owner 'apache'
    end

    variables(
        :debug => (node['config']['core']['debug'] rescue nil),
        :salt => (node['config']['security']['salt'] rescue nil),
        :cipher_seed => (node['config']['security']['cipher_seed'] rescue nil),
        :prefixes => (node['config']['prefixes'] rescue "'admin'"),
        :cache_engine => (node['config']['cache']['engine'] rescue nil),
        :cache_session_server => (node['config']['cache']['session_server'] rescue nil),
        :cache_data_server => (node['config']['cache']['data_server'] rescue nil),
        :hostname => (node[:opsworks][:instance][:hostname] rescue nil),
        :timestamp => Time.now.to_i
    )

    only_if do
      File.directory?("#{deploy[:deploy_to]}/current/#{app_dir}Config")
    end
  end

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
        :avatax_account_number_test => (node['config']['avalar']['accountNumberTest'] rescue nil),
        :avatax_license_key_test => (node['config']['avalar']['licenseKeyTest'] rescue nil),
        :avatax_service_url_test => (node['config']['avalar']['serviceURLTest'] rescue nil),
        :avatax_account_number_live => (node['config']['avalar']['accountNumberLive'] rescue nil),
        :avatax_license_key_live => (node['config']['avalar']['licenseKeyLive'] rescue nil),
        :avatax_service_url_live => (node['config']['avalar']['serviceURLLive'] rescue nil),
        :email_parsing_username => (node['config']['emailParse']['username'] rescue nil),
        :email_parsing_password => (node['config']['emailParse']['password'] rescue nil),
        :email_parsing_connection_string => (node['config']['emailParse']['connection_string'] rescue nil),
        :email_parsing_backlog => (node['config']['emailParse']['backlog'] rescue nil),
        :strongview_username => (node['config']['strongview']['username'] rescue nil),
        :strongview_password => (node['config']['strongview']['password'] rescue nil),
        :strongview_organization => (node['config']['strongview']['username'] rescue nil),
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
        :auth_test_key => (node['config']['auth']['test_key'] rescue nil)
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

  #set permissions on cake console
  file "#{deploy[:deploy_to]}/current/#{app_dir}Console/cake" do
    if platform?('ubuntu')
      owner 'www-data'
    elsif platform?('amazon')
      owner 'apache'
    end
    group deploy[:group]
    mode 0550
    action :touch
  end

  #set tmp permissions, create if needed
  directory "#{deploy[:deploy_to]}/current/#{app_dir}tmp" do
    mode 0740
    group deploy[:group]
    if platform?('ubuntu')
      owner 'www-data'
    elsif platform?('amazon')
      owner 'apache'
    end
    action :create
  end

  #create tmp subdirectories
  %w{cache logs sessions tests}.each do |dir|
    directory "#{deploy[:deploy_to]}/current/#{app_dir}tmp/#{dir}" do
      mode 0740
      group deploy[:group]
      if platform?('ubuntu')
        owner 'www-data'
      elsif platform?('amazon')
        owner 'apache'
      end
      action :create
      recursive true
    end
  end

  #create cache subdirectories
  %w{models persistent views long short}.each do |dir|
    directory "#{deploy[:deploy_to]}/current/#{app_dir}tmp/cache/#{dir}" do
      mode 0740
      group deploy[:group]
      if platform?('ubuntu')
        owner 'www-data'
      elsif platform?('amazon')
        owner 'apache'
      end
      action :create
      recursive true
    end
  end

  #if plugins directory exists iterate over each doing migrations for those with migration scripts
  if File.directory?("#{deploy[:deploy_to]}/current/#{app_dir}Plugin")
    Dir.foreach("#{deploy[:deploy_to]}/current/#{app_dir}Plugin") do |item|
      next if item == '.' or item == '..'  or Dir["#{deploy[:deploy_to]}/current/#{app_dir}Plugin/#{item}/Config/Migration"].empty?
      Chef::Log.info("Running migrations for #{item}")
      execute 'cake migration' do
        cwd "#{deploy[:deploy_to]}/current/#{app_dir}"
        command "./Console/cake Migrations.migration run all --plugin #{item}"
        if platform?('ubuntu')
          user 'www-data'
        elsif platform?('amazon')
          user 'apache'
        end
        action :run
        returns 0
      end
    end
  end

  #if app has migrations run them
  if File.directory?("#{deploy[:deploy_to]}/current/#{app_dir}Config/Migration")
    Chef::Log.info("Running migrations for app")
    execute 'cake migration' do
      cwd "#{deploy[:deploy_to]}/current/#{app_dir}"
      command './Console/cake Migrations.migration run all'
      if platform?('ubuntu')
        user 'www-data'
      elsif platform?('amazon')
        user 'apache'
      end
      action :run
      returns 0
    end
  end
end
