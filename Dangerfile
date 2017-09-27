message "@#{github.pr_author} Thank you for your pull request! I'm here to help with some tips and recommendations. Please take a look at the list provided and help us review and accept your contribution!"

message "Your pull request is on the `master` branch. Please [make a separate feature branch](https://publiclab.org/wiki/contributing-to-public-lab-software#A+sample+git+workflow)) with a descriptive name like `new-blog-design` while making PRs in the future." if github.branch_for_head == 'master'

unless git.commits.any? { |c| c.message =~ /#[\d]+/ }
  message "This pull request doesn't link to a issue number. Please refer to the issue it fixes (if any) in the body of your PR, in the format: `Fixes #123`."
end

if git.added_files.include?("Gemfile.lock") && !git.added_files.include?("Gemfile")
  warn "You have added your `Gemfile.lock` file -- which is most likely not necessary, since you have not changed the Gemfile. Please [remove your changes to this file](https://stackoverflow.com/questions/215718/reset-or-revert-a-specific-file-to-a-specific-revision-using-git) to leave it as it was, thank you! If you really do mean to add Gemfile.lock, just leave a note explaining why. Thanks!"
end

if git.added_files.any? { |files| files.start_with? "db/migrate/" } && !git.added_files.include?("schema.rb.example")
  warn "New migrations added. Please update `schema.rb.example` by overwriting it with a copy of the up-to-date `db/schema.rb`."
end

if git.commits.any? { |c| c.message =~ /^Merge branch 'master'/ }
  warn "It looks like you merged from master in this pull request. Please [rebase](https://help.github.com/articles/about-git-rebase/) to get rid of the merge commits -- you may want to [rewind the master branch and rebase](https://publiclab.org/wiki/contributing-to-public-lab-software#Rewinding+the+master+branch) instead of merging in from master, which can cause problems when accepting new code!"
end

can_merge = github.pr_json["mergeable"]
warn("This pull request cannot be merged yet due to merge conflicts. Please resolve them -- probably by [rebasing](https://help.github.com/articles/about-git-rebase/) -- and ask for help (in the comments, or [in the chatroom](https://gitter.im/publiclab/publiclab) if you get into trouble!.", sticky: false) unless can_merge

if github.pr_body.include?("* [ ]") && !github.pr_title.include?("[WIP]")
  message "It looks like you haven't marked all the checkboxes. Help us review and accept your suggested changes by going through the steps one by one. If it is still a 'Work in progresss', please include '[WIP]' in the title."
end

message "Pull Request is marked as Work in Progress" if github.pr_title.include? "[WIP]"

junit.parse "output.xml"
junit.failures.collect(&:nodes).flatten.each do |failure|
  failure.nodes.each do |f|
    match = f.match(/(test[a-z_\/]+.rb):([0-9]+)/)
    source_path = match[1]
    line = match[2]
    if !source_path.nil? && !line.nil?
      f = f.gsub(source_path + ':' + line, "<a href='https://github.com/#{github.pr_author}/plots2/tree/#{github.branch_for_head}/#{source_path}#L#{line}'>#{source_path}:#{line}</a>")
    end
    fail("There was a test failure at: #{f}")
  end
end

junit.errors.collect(&:nodes).flatten.each do |error|
  error.nodes.each do |f|
    match = f.match(/(test[a-z_\/]+.rb):([0-9]+)/)
    source_path = match[1]
    line = match[2]
    if !source_path.nil? && !line.nil?
      f = f.gsub(source_path + ':' + line, "<a href='https://github.com/#{github.pr_author}/plots2/tree/#{github.branch_for_head}/#{source_path}#L#{line}'>#{source_path}:#{line}</a>")
    end
    fail("There was a test error at: #{f}")
  end
end
