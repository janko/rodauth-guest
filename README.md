# rodauth-guest

Provides guest user functionality for [Rodauth].

## Installation

Add the gem to your project:

```sh
$ bundle add rodauth-guest
```

## Usage

Start by enabling the `guest` feature in your Rodauth configuration: 

```rb
plugin :rodauth do
  enable :guest
end
```

The feature provides the ability to automatically create and log in anonymous accounts when no account is not logged in. You just need to choose for which routes you want to allow guest users:

```rb
route do |r|
  r.rodauth # route rodauth requests

  if r.path.start_with?("/dashboard")
    rodauth.allow_guest
  end
end
```

The guest account will be logged in the same way normal accounts are, so `logged_in?` & `authenticated?` will return `true`, and `session_value` will return the guest account ID. You can check whether a guest account is logged in:

```rb
if rodauth.guest_logged_in?
  # ...
end
```

### Guest creation

Guest accounts are unverified by default, and have a random email address in the form of `guest_<RANDOM_STRING>@example.com`.

```rb
rodauth.account_from_session
rodauth.account #=> { id: 1, status_id: 1, email: "guest_32978759-77bc-4293-ab8f-f1b96b9f178b@example.com" }
```

You can set additional column data on guest account creation:

```rb
# in a schema migration:
add_column :accounts, :guest, :boolean, default: true
```
```rb
before_create_guest do
  account[:guest] = true
end
```

To override new email generation:

```rb
new_guest_login { "guest_#{SecureRandom.hex}@example.com" }
```

Or just the unique suffix:

```rb
guest_unique_suffix { SecureRandom.hex }
```

### Guest deletion

The logged in guest account is automatically deleted when a new account is created. You can use a before hook to transfer any data from the guest account into the new user:

```rb
before_delete_guest do
  # session_value - guest account ID
  # account_id - new account ID
  db[:articles].where(account_id: session_value).update(account_id: account_id)
end
```

You can also skip deletion of the guest record on account creation (by default it's skipped when `create_account_autologin?` is `false`):

```rb
delete_guest_on_create? false
```

## Development

Run tests with Rake:

```sh
$ bundle exec rake test
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/janko/rodauth-guest. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/janko/rodauth-guest/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rodauth::Guest project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/janko/rodauth-guest/blob/main/CODE_OF_CONDUCT.md).

[Rodauth]: https://github.com/jeremyevans/rodauth
