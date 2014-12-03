require 'csv'

desc "Import users from a CSV file"
task :import_users, [:csv_file] => [:environment] do |_, args|
  CSV.foreach(args[:csv_file], col_sep: ';', headers: true) do |user|

    if User.where(email: user['email']).first
      puts "User #{user['email']} already exists and is not imported."
    else
      u = User.new({
        username: user['username'] || UserNameSuggester.suggest(user['email']),
        email: user['email'],
        password: SecureRandom.hex,
        name: user['name'],
        title: user['title'],
        approved: true,
        approved_by_id: -1
      })
      u.import_mode = true
      u.groups = parse_user_groups user['groups']
      u.save

      puts "Imported #{u.name} (#{u.email}) as #{u.username}"
    end

  end
end

def parse_user_groups(groups)
  return [] if groups.blank?
  groups.split(',').map do |group|
    Group.where(name: group).first
  end
end
