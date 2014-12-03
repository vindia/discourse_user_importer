require 'csv'

desc "Import users from a CSV file"
task "import:csv_users" => :environment do
  CSV.foreach('users.csv', col_sep: ';', headers: true) do |user|
    if User.where(email: user['email']).first
      puts "User #{user['email']} already exists and is not imported."
    else
      user = User.new({
        username: user['username'] || UserNameSuggester.suggest(user['email']),
        email: user['email'],
        password: SecureRandom.hex,
        name: user['name'],
        title: user['title']
      })
      user.import_mode = true
      user.groups = parse_user_groups(user[:groups])
      user.save
    end
  end
end

def parse_user_groups(groups)
  return if groups.blank?
  groups.split(',').map do |group|
    Group.where(name: group).first
  end
end
