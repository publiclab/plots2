### How to be a GCI mentor

To be a GCI mentor at Public labs, there are some prerequisites that we expect you to follow before we can invite you to be a mentor :

1. Solve a [fto issue](https://code.publiclab.org/). Provide the link to the first timer issue's pull request (PR) once it's merged.

2. Solve a [help-wanted issue](https://github.com/publiclab/plots2/labels/help-wanted). Help wanted issues are issues which are not labelled as `gci-candidate` neither as `fto-candidate` nor as `first-timer-only`. Provide link to such issues' merged PR.

**(Make sure you claim the issue first by commenting on issue you are planning to solve). This is very important.**

3. Create a **first-timers issue.** [Use the extra friendly template](https://publiclab.org/notes/warren/10-31-2016/create-a-welcoming-first-timers-only-issue-to-invite-new-software-contributors) which we generally use for creating our first timer issues. Provide the link to the first timer issue which is created by you.

4. Once done with all these, fill [this](https://docs.google.com/forms/d/e/1FAIpQLScSBS-ddZN2H-lviUJbKlbV2VwP21fdIutXOCBzigRhmXJybw/viewform?usp=sf_link) form.
<hr>

* To be a mentor you don't necessarily need to know how to code -- we need mentors who know Public Lab's community and practices well, and who can encourage students to speak up when they get stuck, and to ask the community for input and testing of their work.

* It's important to understand that people need to do only a single `first-timer-only` issue.

* A first-timers-issue is meant to welcome people to open-source and should be easy enough to understand to make them feel comfortable. Use the [extra-friendly template](https://publiclab.org/n/13667) when creating `first-timer` issues.

* Once done with that, they need to move on to `help-wanted` issues. **As a mentor, you need to assist them in these areas.**

* A `help-wanted` issue is a bit more hard to tackle and people can move onto this once they find themselves comfortable by solving one `first-timer` issue. 

* As a mentor you need to report bugs, suggest changes, create ``help wanted`` and ``first timer issues``, add bugs/suggestions to https://github.com/publiclab/plots2/issues/3276, and review ``help-wanted issues`` also.

* As a mentor, you also need to guide students to create good `first-timer` issues and help them in reviewing PRs.

* We want to move towards a self-sustainable system where people make and review the PRs amongst themselves.

* If you are creating a `gci-candidate issue` format it properly with
lines like

**We are preparing to participate in Google Code-in, and have reserved this issue for participants in GCI - but we'd love to have your help with another one! Please check out [https://code.publiclab.org](https://code.publiclab.org) to see more.**

* When creating an issue for GCI, you need to list the potential solutions too.

* You can open issues in any repository belonging to Public Lab whether it is on Ruby on Rails, Javascript, or any other tech stack including [plots2](https://github.com/publiclab/plots2),[image-sequencer](https://github.com/publiclab/image-sequencer), [leaflet](https://github.com/publiclab?utf8=%E2%9C%93&q=leaflet&type=&language=), [plotsbot](https://github.com/publiclab/plotsbot).

* A GCI issue needs to be put in the [staging list](https://github.com/publiclab/plots2/issues/3276) as well.

* You also need to mention the category of the issue from these recurring tasks: Code, Design, Documentation/training, Quality Assurance, Outreach and add the instance count, i.e., how many people can take that issue in the issue description(https://github.com/publiclab/plots2/wiki/Google-Code-In-Tasks).

* Labels which we can use at publiclab after creating issues are bug, design, enhancement, refactorization, documentation, help-wanted, and support.

* For GCI issue you need to create the same task on the GCI dashboard as well.

* You need to use extra-friendly tone at Public Lab with people.
<hr>

**PR Review Guidelines:**

1. Issue should be claimed before opening the pull request.

2. PR should use 'Fixes #issue_no" in PR body.

3. PR should have description in title.

4. Code should be modular.

5. Add screenshots if applicable.

6. Tests must be written if needed. All tests must pass before approval.

7. Suggest code changes if any. Else approve the PR by commentting in the PR.

8. PR is (ideally) less than 50 lines of code & generally tries to implement only a single feature or fix.

9. PR doesn't affect highly sensitive areas of the site such as header or top of dashboard or signup form without input from @publiclab/community-reps

10. Check Gemfile.lock, yarn.lock, and other unrelated files are not included

11. Double check if it contains any feature that will be difficult to roll back(Possibly ask for review from other reviewers as well).

12. Label as review-me if review required from another reviewer.
