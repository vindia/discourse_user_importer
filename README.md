# Discourse User Importer
This script will create users for a Discourse installation given a CSV file with
users.

Some features include:

* Password is automatically generated, but your users need to reset it
* Imported users are automatically approved by the system user (`id: -1`)
* Users can be automatically assigned to one or more predefined groups

Caveats:

* Error handling may be a little rough. Please check beforehand if all data in
  your CSV-file is correct, e.g. that the groups you want to use already exist.

## Import file format

    email;name;username;title;groups

Field      | Required | Description
-----------|----------|------------
`email`    | **Yes**  | The email address of the user
`name`     | **Yes**  | The user's full name
`username` | No       | The user's user name. If none is supplied, this will be generated from the email address.
`title`    | No       | The user's title, e.g. _Vice President of Engineering_
`groups`   | No       | A comma separated list of groups a user should be added to. When left empty, the user will not be added to any specific groups.

## On passwords
For each user a random password is generated using `SecureRandom.hex`. Users
are able to set their own password after importing by using the password reset
function in Discourse.

## Running it
Add this file to your `lib/tasks` and run do:

    $ rake import_users[/path/to/users.csv]

## After running this script
Since users are automatically approved, they can log in right away after running
this script. Because the user's password is an automatically generated random
string, a newly imported user can only log in by generating a new password
through the password reset function in Discourse. They will then receive a link
to set a new password in their email.
