class Search < ActiveRecord::Base

  def users(params)
    @users ||= find_users(params)
  end

  def find_users(input)
    DrupalUsers.where('name LIKE ? AND access != 0', '%' +input+ '%')
        .order("uid")
        .limit(5)
  end

end
