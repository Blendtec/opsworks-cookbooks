#
# Cookbook Name:: composer 
# Recipe:: install
#

node[:deploy].each do |app_name, deploy|

  script "install_composer" do
    interpreter "bash"
    user 'root'
    cwd "#{deploy[:deploy_to]}/current"
    code <<-EOH
    php5enmod mcrypt
    service apache2 restart
    EOH
  end

end
