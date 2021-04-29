# Feature maintainers

We've been working towards a more shared model of maintainer responsibilities. This is a pilot project to share merge rights among a group of maintainers, but divided up into "feature areas" which are listed below.

Some are large and some small. But people who want to just get started can join one with a narrow set of responsibilities -- like database or navbar -- which have few moving parts and mainly just are there to ensure that those areas are stable. Others may get more involved in a complex integrated system like comments or editor.

We use the GitHub feature called [Code Owners](https://help.github.com/en/articles/about-code-owners), which can **automatically generate a review request** for a user (or group!) based on if a pull request has changed files in a particular folder. 

This is really cool and it brings up the possibility of having groups that have merge rights but are responsible for only specific areas of the codebase. This will make it easier to know enough about a system to give a good final check (after reviews) and be sure it doesn't break anything, without having to know the entire codebase. This can then reduce our merge-rights bottleneck, but not bring a lot of risk of breaking code.

See more discussion on this system in this issue: https://github.com/publiclab/plots2/issues/6501

## Feature areas

So, for example, we might have a @publiclab/comments-maintainers group, who have merge rights and responsibilities for the comments feature area -- including:

```
/app/models/comment.rb
/app/controllers/comment_controller.rb
/app/views/comments/
/app/views/notes/_comment.html.erb
/app/views/notes/_comments.html.erb
/test/unit/comment_test.rb
/test/unit/comment_mailer_test.rb
/test/functional/comment_controller_test.rb
/test/functional/comment_mailer_test.rb
```

These are actually each listed out in [the CODEOWNERS file](https://github.com/publiclab/plots2/blob/a2dfdf20c6bbfaa6af60201881361c5342f676ef/.github/CODEOWNERS#L39-L49), with @publiclab/comment-maintainers after each line.

Note: we are adding these to the CODEOWNERS file progressively, and would love help expanding out that list. 


## Goals and priorities

Each feature area has its own goals and priorities. Some are more stable, and the goal is keeping them updated, error-free, and high test coverage. This could include the front page of the site, which we don't want to change much. 

Others may need a lot of work and improvements, and need to be seeing lots of new things written, from features to tests. 

Each type comes with a different "attitude" towards merging. Some need to be REALLY careful if they're critical systems like login/authentication, where a mistake could break the site. 


## Login maintainers

1. ensure functional login system on live site
2. be aware of changes that could impact login
3. review and merge dependency updates via @dependabot
4. ensure stability and maintainability of login system

## Comment maintainers

1. ensure commenting is error-free
2. improve and refine commenting UI
3. maintain commenting from a mobile phone
4. maintain comment-by-email
5. simplify and clean commenting code
6. consolidate and refine commenting code
7. increase test coverage, esp. full-stack system tests

## Editor maintainers

1. reduce bugs
2. maintain integration with https://github.com/publiclab/PublicLab.Editor/
3. refine editor UI
4. expand editor test coverage
5. ?

## Database maintainers

1. resolve emoji issue
2. gradually reduce # of tables (https://github.com/publiclab/plots2/issues/956)
3. manage optimizations

## Navbar maintainers

1. preserve navbar style and responsiveness

## Profile maintainers

1. ?
