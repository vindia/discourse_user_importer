require 'csv'

namespace :user_importer do
  desc "Import users from a CSV file"
  task :import, [:csv_file] => [:environment] do |_, args|
    abort "Please specify the CSV file to import" if args[:csv_file].blank?

    CSV.foreach(args[:csv_file], col_sep: ';', headers: true) do |new_user|
      user = User.where(email: new_user['email']).first
      if user
        new_groups = new_user_groups(new_user['groups']) - user.groups.map(&:name)
        user.groups << parse_user_groups(new_groups)

        puts "User #{new_user['email']} already exists and is not imported."
        puts ">> #{new_user['email']} was added to #{new_groups.join(',')}" unless new_groups.empty?
      else
        u = User.new({
          username: new_user['username'] || UserNameSuggester.suggest(new_user['email']),
          email: new_user['email'],
          password: SecureRandom.hex,
          name: new_user['name'],
          title: new_user['title'],
          approved: true,
          approved_by_id: -1,
          trust_level: 1
        })
        u.import_mode = true
        u.groups = parse_user_groups new_user['groups']

        if u.save
          puts "Imported #{u.name} (#{u.email}) as #{u.username} to #{u.groups.map(&:name).join(',')}"
        else
          puts "Could not import #{u.name} (#{u.email}) due to #{u.errors.messages}"
        end
      end

    end
  end

  desc "Check usernames of users to be imported"
  task :check, [:csv_file] => [:environment] do |_, args|
    abort "Please specify the CSV file to import" if args[:csv_file].blank?

    CSV.foreach(args[:csv_file], col_sep: ';', headers: true) do |new_user|

      if new_user['username']
        user = User.where(username: new_user['username']).first

        if user
          puts "Username #{new_user['username']} (#{new_user['email']}) already exists for user: #{user.name} (#{user.email})"
        else
          puts "Username #{new_user['username']} is free to use!"
        end

      else
        puts "No username supplied for #{new_user['email']}, ignoring..."
      end

    end
  end
end

def new_user_groups(groups)
  groups.split(',')
end

def parse_user_groups(groups)
  return [] if groups.blank?
  new_user_groups(groups).map do |group|
    Group.where(name: group).first_or_create
  end
end
