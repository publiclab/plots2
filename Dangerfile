message "@#{github.pr_author} Thank you for your PR. Please correct any issues above, if any."

warn "Make a separate branch while making PRs in future" if github.branch_for_head == 'master'

unless git.commits.any? { |c| c.message =~ /#[\d]+/ }
  warn "Commits doesn't link to a issue no. Please include a issue no if any in the format Fixes #issue_no."
end

warn "You have multiple commits. Please squash them if changes are small." if git.commits.size > 1

if git.added_files.any? { |files| files.start_with? "db/migrate/" } && !git.added_files.include?("schema.rb.example")
  warn "New migrations added. Please update schema.rb.example."
end

if git.commits.any? { |c| c.message =~ /^Merge branch 'master'/ }
  warn "Please rebase to get rid of the merge commits in this PR. Check https://publiclab.org/wiki/contributing-to-public-lab-software#Rewinding+the+master+branch"
end

can_merge = github.pr_json["mergeable"]
warn("This PR cannot be merged yet. Please resolve the merge conflicts.", sticky: false) unless can_merge

if github.pr_body.include?("* [ ]") && !github.pr_title.include?("[WIP]")
  warn "You haven't marked all the checkboxes. Ensure that you have followed it by marking the checkboxes. If it is Work in progresss include [WIP] in PR title."
end

warn "Pull Request is marked as Work in Progress" if github.pr_title.include? "[WIP]"
