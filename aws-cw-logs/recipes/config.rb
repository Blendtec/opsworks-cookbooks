#config.rb

template "/etc/cwlogs.cfg" do
  cookbook "aws-cw-logs"
  source "cwlogs.cfg.erb"
  owner "root"
  group "root"
  mode 0644
end