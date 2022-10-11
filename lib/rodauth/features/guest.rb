require "securerandom"

module Rodauth
  Feature.define(:guest, :Guest) do
    before "create_guest"
    after "create_guest"
    before "delete_guest"
    after "delete_guest"

    auth_value_methods :delete_guest_on_create?

    auth_methods(
      :guest_logged_in?,
      :create_guest,
      :save_guest,
      :delete_guest,
      :new_guest_login,
      :guest_unique_suffix,
    )

    auth_private_methods(
      :new_guest,
    )

    def allow_guest
      @guest_allowed = true
      return if logged_in?

      create_guest
      login_session("guest")
    end

    def logged_in?
      super unless guest_logged_in? && !guest_allowed?
    end

    def create_guest
      new_guest
      before_create_guest
      save_guest
      after_create_guest
    end

    def new_guest
      @account = _new_guest
    end

    def save_guest
      account[account_id_column] = db[accounts_table].insert(account)
    end

    def guest_logged_in?
      authenticated_by && authenticated_by.include?("guest")
    end

    private

    def after_create_account
      super if defined?(super)
      if guest_logged_in? && delete_guest_on_create?
        before_delete_guest
        delete_guest
        after_delete_guest
      end
    end

    def delete_guest
      account_ds(session_value).delete
    end

    def delete_guest_on_create?
      create_account_autologin?
    end

    def account_session_status_filter
      return {} if guest_logged_in?
      super
    end

    def guest_allowed?
      @guest_allowed
    end

    def _new_guest
      { login_column => new_guest_login }
    end

    def new_guest_login
      "guest_#{guest_unique_suffix}@example.com"
    end

    def guest_unique_suffix
      SecureRandom.uuid
    end
  end
end
