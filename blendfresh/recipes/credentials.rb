#
# Cookbook Name:: blendtec
# Recipe:: credentials
#

node[:deploy].each do |app_name, deploy|
  Chef::Log.info("CakePHP deploy #{app_name} to #{deploy[:deploy_to]}/current/#{app_name}")

  app_dir = node[:config][:app_dir] rescue "app/"

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
