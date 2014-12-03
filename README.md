# Discourse User Importer
This script will create users for a Discourse installation given a CSV file with
users.

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
