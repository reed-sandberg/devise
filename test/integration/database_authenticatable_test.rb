require 'test_helper'

class DatabaseAuthenticationTest < ActionController::IntegrationTest
  test 'sign in with email of different case should succeed when email is in the list of case insensitive keys' do
    create_user(:email => 'Foo@Bar.com')
    
    sign_in_as_user do
      fill_in 'email', :with => 'foo@bar.com'
    end
    
    assert warden.authenticated?(:user)
  end

  test 'sign in with email of different case should fail when email is NOT the list of case insensitive keys' do
    swap Devise, :case_insensitive_keys => [] do
      create_user(:email => 'Foo@Bar.com')
      
      sign_in_as_user do
        fill_in 'email', :with => 'foo@bar.com'
      end
      
      assert_not warden.authenticated?(:user)
    end
  end
  
  test 'sign in with email including extra spaces should succeed when email is in the list of strip whitespace keys' do
    create_user(:email => ' foo@bar.com ')
    
    sign_in_as_user do
      fill_in 'email', :with => 'foo@bar.com'
    end
    
    assert warden.authenticated?(:user)
  end

  test 'sign in with email including extra spaces should fail when email is NOT the list of strip whitespace keys' do
    swap Devise, :strip_whitespace_keys => [] do
      create_user(:email => 'foo@bar.com')
      
      sign_in_as_user do
        fill_in 'email', :with => ' foo@bar.com '
      end
      
      assert_not warden.authenticated?(:user)
    end
  end

  test 'sign in should not authenticate if not using proper authentication keys' do
    swap Devise, :authentication_keys => [:username] do
      sign_in_as_user
      assert_not warden.authenticated?(:user)
    end
  end

  test 'sign in with invalid email should return to sign in form with error message' do
    sign_in_as_admin do
      fill_in 'email', :with => 'wrongemail@test.com'
    end

    assert_contain 'Invalid email or password'
    assert_not warden.authenticated?(:admin)
  end

  test 'sign in with invalid pasword should return to sign in form with error message' do
    sign_in_as_admin do
      fill_in 'password', :with => 'abcdef'
    end

    assert_contain 'Invalid email or password'
    assert_not warden.authenticated?(:admin)
  end

  test 'error message is configurable by resource name' do
    store_translations :en, :devise => { :failure => { :admin => { :invalid => "Invalid credentials" } } } do
      sign_in_as_admin do
        fill_in 'password', :with => 'abcdef'
      end

      assert_contain 'Invalid credentials'
    end
  end

  test 'encrypted_password should reflect changes in stretches confir param' do
    user = create_user
    encrypted_password = user.reload.encrypted_password
    user.class.stretches += 1
    sign_in_as_user
    assert_not_equal encrypted_password, user.reload.encrypted_password
  end
end
