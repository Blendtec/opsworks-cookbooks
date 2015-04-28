#
# Cookbook Name:: php 
# Recipe:: enable_modules
#

node[:deploy].each do |app_name, deploy|

  script "enable_modules" do
    interpreter "bash"
    user 'root'
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
    php5enmod mcrypt
    service apache2 restart
    EOH
  end

end
