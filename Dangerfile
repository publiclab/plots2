message "@#{github.pr_author} Thank you for your pull request! I'm here to help with some tips and recommendations. Please take a look at the list provided and help us review and accept your contribution!"

message "Your pull request is on the `master` branch. Please [make a separate feature branch](https://publiclab.org/wiki/contributing-to-public-lab-software#A+sample+git+workflow)) with a descriptive name like `new-blog-design` while making PRs in the future." if github.branch_for_head == 'master'

unless git.commits.any? { |c| c.message =~ /#[\d]+/ }
  message "This pull request doesn't link to a issue number. Please refer to the issue it fixes (if any) in the format: `Fixes #123`."
end

message "You have added multiple commits. It's helpful to [squash them](http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html) if the individual changes are small." if git.commits.size > 1

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
