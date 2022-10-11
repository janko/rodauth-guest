require "test_helper"

describe "Rodauth guest feature" do
  it "allows automatically creating a guest account" do
    rodauth do
      enable :guest
    end
    roda do |r|
      r.rodauth
      rodauth.allow_guest
      r.root do
        view content: "Authenticated by: #{rodauth.authenticated_by}, Guest logged in: #{rodauth.guest_logged_in?}, Logged in: #{!!rodauth.logged_in?}"
      end
    end

    visit "/"
    assert_includes page.html, %(Authenticated by: ["guest"], Guest logged in: true, Logged in: true)

    assert_equal 1, DB[:accounts].count
    account = DB[:accounts].first
    assert_match /^guest_.+@example.com$/, account[:email]
    assert_equal 1, account[:status_id]
  end

  it "allows retrieving guest account" do
    rodauth do
      enable :guest
    end
    roda do |r|
      r.rodauth
      rodauth.allow_guest
      rodauth.account_from_session unless rodauth.account
      r.root do
        view content: "Account: #{rodauth.account[:id]}"
      end
    end

    visit "/"
    assert_includes page.html, "Account: 1"

    visit "/"
    assert_includes page.html, "Account: 1"
  end

  it "doesn't automatically create a guest account when not enabled" do
    rodauth do
      enable :guest
    end
    roda do |r|
      r.rodauth
      r.get "guest" do
        rodauth.allow_guest
        view content: "Guest page: #{rodauth.session_value}"
      end
      r.root do
        view content: "Logged in: #{!!rodauth.logged_in?}, Guest logged in: #{rodauth.guest_logged_in?}"
      end
    end

    visit "/guest"
    assert_includes page.html, "Guest page: 1"

    visit "/"
    assert_includes page.html, "Logged in: false, Guest logged in: true"

    visit "/guest"
    assert_includes page.html, "Guest page: 1"
  end

  it "deletes previous guest account on account creation" do
    rodauth do
      enable :guest, :create_account
    end
    roda do |r|
      r.rodauth
      rodauth.allow_guest
      r.root do
        view content: "Logged in: #{rodauth.logged_in?}, Guest logged in: #{rodauth.guest_logged_in?}"
      end
    end

    visit "/"
    assert_equal 1, DB[:accounts].count

    create_account
    assert_equal "Your account has been created", page.find("#notice_flash").text
    assert_includes page.html, "Logged in: 2, Guest logged in: false"

    assert_equal 1, DB[:accounts].count
    account = DB[:accounts].first
    assert_equal 2, account[:id]
    assert_equal "user@example.com", account[:email]
    assert_equal 2, account[:status_id]
  end

  it "doesn't delete previous guest account if create account autologin is disabled" do
    rodauth do
      enable :guest, :create_account
      create_account_autologin? false
    end
    roda do |r|
      r.rodauth
      rodauth.allow_guest
      r.root do
        view content: "Logged in: #{rodauth.logged_in?}, Guest logged in: #{rodauth.guest_logged_in?}"
      end
    end

    visit "/"
    create_account

    assert_equal "Your account has been created", page.find("#notice_flash").text
    assert_includes page.html, "Logged in: 1, Guest logged in: true"
    assert_equal 2, DB[:accounts].count
  end

  it "allows transferring guest data on account creation" do
    DB.create_table :articles do
      primary_key :id
      foreign_key :account_id, :accounts, null: false
      String :title, null: false
    end

    rodauth do
      enable :guest, :create_account
      before_delete_guest do
        DB[:articles].where(account_id: session_value).update(account_id: account_id)
      end
    end
    roda do |r|
      r.rodauth
      rodauth.allow_guest
      r.root { view content: "Home page" }
    end

    other_account_id = DB[:accounts].insert(email: "other@example.com")
    DB[:articles].insert(title: "Other", account_id: 1)

    visit "/"
    DB[:articles].insert(title: "Guest", account_id: 2)

    create_account
    assert DB[:articles].where(account_id: 2).empty?
    assert_equal 1, DB[:articles].where(account_id: 3).count
    assert_equal 1, DB[:articles].where(account_id: 1).count
  end

  it "allows storing additional data on guest record" do
    DB.add_column :accounts, :guest, :boolean, default: false

    rodauth do
      enable :guest, :create_account
      new_guest { super().merge(guest: true) }
    end
    roda do |r|
      r.rodauth
      rodauth.allow_guest
      r.root { view content: "Home page" }
    end

    visit "/"
    assert_equal true, DB[:accounts].get(:guest)
  end
end
