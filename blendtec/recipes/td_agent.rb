
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
        :bucket => (node['config']['td_agent']['bucket'] rescue nil),
        :s3_end_point => (node['config']['td_agent']['end_point'] rescue nil),
        :apache_dir => (node[:apache][:dir] rescue nil),
        :path => (node['td_agent'][path]),
        :apache_s3_object_key_format => (node['td_agent'][apache_s3_object_key_format]),
        :apache_buffer_path => (node['td_agent'][apache_buffer_path]),
        :apache_error_s3_object_key_format => (node['td_agent'][apache_error_s3_object_key_format]),
        :apache_error_buffer_path => (node['td_agent'][apache_error_buffer_path]),
        :time_slice_format => (node['td_agent'][time_slice_format]),
        :time_slice_wait => (node['td_agent'][time_slice_wait]),
        :time_zone => (node['td_agent'][time_zone]),
        :buffer_chunk_limit => (node['td_agent'][buffer_chunk_limit]),
        :access_s3_object_key_format => (node['td_agent'][access_s3_object_key_format]),
        :access_buffer_path => (node['td_agent'][access_buffer_path]),
        :access_error_s3_object_key_format => (node['td_agent'][access_error_s3_object_key_format]),
        :access_error_buffer_path => (node['td_agent'][access_error_buffer_path])
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
