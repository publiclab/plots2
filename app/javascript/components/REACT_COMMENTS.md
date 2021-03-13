# `React Commenting System`

**Last Updated: 3/13/2021**

This documents the React rewrite of the commenting system that PR #9176 initiated. Also see the corresponding issue at #9175.

## `How to Access`

The React comments system runs in parallel to the standard one.

To see it in production, visit any **research note** and copy-and-paste the following parameter to the end of the URL:

### `?react=true`

**NOTE:** React comments aren't available for **wikis** or **questions**.

## `Behind the Scenes`

When the user visits a research note with `?react=true`, the server bundles up a JSON object containing that research note's initial comments state. For example:

```
@react_props = {
  currentUser: current_user_json,
  comments: comments,
  elementText: {
    commentFormPlaceholder: I18n.t('notes._comments.post_placeholder'),
    commentsHeaderText: helpers.translation('notes._comments.comments'),
    commentPreviewText: helpers.translation('comments._form.preview'),
    commentPublishText: helpers.translation('comments._form.publish'),
    userCommentedText: helpers.translation('notes._comment.commented')
  },
  node: {
    nodeId: @node.id,
    nodeAuthorId: @node.uid
  },
  user: current_user
}
```

Rather than rendering a Rails template, the front-end uses this JSON object to build out the commenting system in React!

The initial comments state cascades down into several components starting with the topmost component `CommentsContainer`. This is standard practice for React. [See the docs for more info](https://reactjs.org/docs/getting-started.html).

## `Known Issues to Be Resolved Soon!`

_(Help Wanted!)_

- You must be logged into the website to see React comments (no guest browsing)
- New React-centric routes must be created, so that the client sends requests to `/comment/REACT/create/46` instead of `/comment/create/46`
- Any contributors MUST install the following linters to protect the React codebase: `plugin:react/recommended`, `plugin:react-hooks/recommended`.
  - We need to fix the `.eslintrc` config to install these linters permanently, and get them working with codeclimate.