# Active Support concerns are a good way to use modules that can used across different models
# Refer to this link: http://stackoverflow.com/questions/14541823/how-to-use-concerns-in-rails-4
module CommentsShared
  extend ActiveSupport::Concern

  # filtered version additionally appending http/https
  #   protocol to protocol-relative URLslike "/foo"
  def body_email(host = 'publiclab.org')
    body.gsub(/([\s|"|'|\[|\(])(\/\/)([\w]?\.?#{host})/, '\1https://\3')
  end

  def author
    DrupalUsers.find_by_uid uid
  end
end
