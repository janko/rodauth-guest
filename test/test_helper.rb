ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "minitest/pride"
require "minitest/hooks/default"

require "capybara/dsl"
require "securerandom"

require "sequel/core"
require "roda"
require "mail"

DB = Sequel.sqlite

DB.create_table :accounts do
  primary_key :id
  Integer :status_id, null: false, default: 1
  String :email, null: false
  String :password_hash
end

Mail.defaults { delivery_method :test }

class Minitest::HooksSpec
  include Capybara::DSL

  private

  attr_reader :app

  def app=(app)
    @app = Capybara.app = app
  end

  def rodauth(&block)
    @rodauth_block = block
  end

  def roda(&block)
    app = Class.new(Roda)
    app.plugin :sessions, secret: SecureRandom.hex(32), key: "rack.session"
    app.plugin :render, layout_opts: { path: "test/views/layout.str" }

    rodauth_block = @rodauth_block
    app.plugin :rodauth do
      skip_status_checks? false
      account_password_hash_column :password_hash
      instance_exec(&rodauth_block)
    end
    app.route(&block)

    self.app = app
  end

  around do |&block|
    DB.transaction(rollback: :always, auto_savepoint: true) { super(&block) }
  end

  after do
    Capybara.reset_sessions!
  end

  def create_account(email: "user@example.com", password: "secret")
    visit "/create-account"
    fill_in "Login", with: email
    fill_in "Confirm Login", with: email
    fill_in "Password", with: password
    fill_in "Confirm Password", with: password
    click_on "Create Account"
  end
end
