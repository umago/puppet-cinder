require 'spec_helper'

describe 'cinder::api' do

  let :req_params do
    {:keystone_password => 'foo'}
  end
  let :facts do
    {:osfamily => 'Debian'}
  end

  describe 'with only required params' do
    let :params do
      req_params
    end

    it { should contain_service('cinder-api').with(
      'hasstatus' => true
    )}

    it 'should configure cinder api correctly' do
      should contain_cinder_config('DEFAULT/auth_strategy').with(
       :value => 'keystone'
      )
      should contain_cinder_config('DEFAULT/osapi_volume_listen').with(
       :value => '0.0.0.0'
      )
      should contain_cinder_api_paste_ini('filter:authtoken/service_protocol').with(
        :value => 'http'
      )
      should contain_cinder_api_paste_ini('filter:authtoken/service_host').with(
        :value => 'localhost'
      )
      should contain_cinder_api_paste_ini('filter:authtoken/service_port').with(
        :value => '5000'
      )
      should contain_cinder_api_paste_ini('filter:authtoken/auth_protocol').with(
        :value => 'http'
      )
      should contain_cinder_api_paste_ini('filter:authtoken/auth_host').with(
        :value => 'localhost'
      )
      should contain_cinder_api_paste_ini('filter:authtoken/auth_port').with(
        :value => '35357'
      )
      should contain_cinder_api_paste_ini('filter:authtoken/auth_admin_prefix').with(
        :ensure => 'absent'
      )
      should contain_cinder_api_paste_ini('filter:authtoken/admin_tenant_name').with(
        :value => 'services'
      )
      should contain_cinder_api_paste_ini('filter:authtoken/admin_user').with(
        :value => 'cinder'
      )
      should contain_cinder_api_paste_ini('filter:authtoken/admin_password').with(
        :value  => 'foo',
        :secret => true
      )

      should contain_cinder_api_paste_ini('filter:authtoken/auth_uri').with(
        :value => 'http://localhost:5000/'
      )

    end
  end

  describe 'with custom auth_uri' do
    let :params do
      req_params.merge({'keystone_auth_uri' => 'http://foo.bar:8080/v2.0/'})
    end
    it 'should configure cinder auth_uri correctly' do
      should contain_cinder_api_paste_ini('filter:authtoken/auth_uri').with(
        :value => 'http://foo.bar:8080/v2.0/'
      )
    end
  end

  describe 'with only required params' do
    let :params do
      req_params.merge({'bind_host' => '192.168.1.3'})
    end
    it 'should configure cinder api correctly' do
      should contain_cinder_config('DEFAULT/osapi_volume_listen').with(
       :value => '192.168.1.3'
      )
    end
  end

  [ '/keystone', '/keystone/admin', '' ].each do |keystone_auth_admin_prefix|
    describe "with keystone_auth_admin_prefix containing incorrect value #{keystone_auth_admin_prefix}" do
      let :params do
        {
          :keystone_auth_admin_prefix => keystone_auth_admin_prefix,
          :keystone_password    => 'dummy'
        }
      end

      it { should contain_cinder_api_paste_ini('filter:authtoken/auth_admin_prefix').with(
        :value => keystone_auth_admin_prefix
      )}
    end
  end

  [
    '/keystone/',
    'keystone/',
    'keystone',
    '/keystone/admin/',
    'keystone/admin/',
    'keystone/admin'
  ].each do |keystone_auth_admin_prefix|
    describe "with keystone_auth_admin_prefix containing incorrect value #{keystone_auth_admin_prefix}" do
      let :params do
        {
          :keystone_auth_admin_prefix => keystone_auth_admin_prefix,
          :keystone_password    => 'dummy'
        }
      end

      it { expect { should contain_cinder_api_paste_ini('filter:authtoken/auth_admin_prefix') }.to \
        raise_error(Puppet::Error, /validate_re\(\): "#{keystone_auth_admin_prefix}" does not match/) }
    end
  end

end
