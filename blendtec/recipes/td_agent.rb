
node[:deploy].each do |app_name, deploy|
  #generate td-agent.conf config file
  template '/etc/td-agent/td-agent.conf' do
    source 'td-agent.conf.erb'
    mode 0440
    owner  'td-agent'
    group  'td-agent'
    variables(
	:application => (app_name rescue nil),
        :key => (node['config']['keys']['logger']['key'] rescue nil),
        :secret => (node['config']['keys']['logger']['secret'] rescue nil),
        :bucket => (node['config']['logging']['bucket'] rescue nil),
        :s3_end_point => (node['config']['logging']['end_point'] rescue nil),
        :apache_dir => (node[:apache][:dir] rescue nil)
    )
    only_if do
      File.directory?('/etc/td-agent/')
    end
  end

  file "/var/log/apache2/access.log" do
    mode "0644"
    action :touch
  end

  file "/var/log/apache2/error.log" do
    mode "0644"
    action :touch
  end
end
