control 'chef-server' do
  describe package('chef-server-core') do
    it { should be_installed }
  end

  describe package('chef-manage') do
    it { should be_installed }
  end

  describe command('chef-manage-ctl status') do
    its(:exit_status) { should eq 0 }
  end

  describe command('sudo chef-sync-ctl sync-status') do
    its(:exit_status) { should eq 0 }
  end
end
