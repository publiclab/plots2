PublicLab.org's Data Model
======

_This page attempts to explain the database model for the plots2 project._

The [following diagram](https://docs.google.com/presentation/d/1aquQKyih8vvtD7U-AI0NlbAcgT-BVu9G8hloYg-c-QI/edit#slide=id.p) is a rough sketch of how the applications various tables interconnect:

![data model diagram](https://user-images.githubusercontent.com/24359/50705765-d84ae000-1029-11e9-9e4c-f166a0c0d5d1.png)

****

## Content

All user-generated content on PublicLab.org is either a Node, an Answer, or a Comment.

### Nodes

Nodes are a general type with primary key `nid`, a `title`, an author `uid`, and a `path`, or relative URL starting with "/".

There are several types of nodes, based on their `type` field:

* **Notes**, or research notes, of type "note", are single-author, single-revision.
* **Wikis**, or wiki pages, of type "page", have many revisions, each of which has an author. They have a path like `/wiki/title` or simply `/title` (for so-called "root" pages).
* **Features**, of type "feature", are blocks of content which can be included (hard-coded) throughout the site, but can only be made by admins. Read more about them below.
* **Maps**, of type "map", are web-map image layers and associated image files, displayed on https://publiclab.org/archive

Nodes may also be redirects, though this use is legacy only. More documentation needed.

Notes (type `note`) can also be a sub-type called Questions, if they have a tag starting with `question:` -- which gives them extra features such as the ability to have Answers (see below).

Node `status` -- a property of `Node`, can be:

* 0: banned
* 1: normal
* 3: draft
* 4: moderated -- i.e. node created by a first-time poster, and has not yet been "approved"

### Drafts

Drafts are a type of Research notes. They can be used by users to save their research notes without publishing them publicly. But, not all users are eligible to create draft.
Only users who have successfully published their first-note would be shown option for creating draft. Draft would be visible to co-author and other users can access it using secret link
shared by author. Different draft-related privileges are mentioned below in the table:

| User Role | Draft Creation | Draft Editing | Draft Publishing |
| ------------ |--------------------|-------------------|-----------------------|
| New Contributor | No | Yes, if co-author made by normal user | Yes, if co-author |
| Normal User | Yes | Yes, if author or co-author | Yes, if author or co-author |
| Moderator and Admin | Yes | Yes | Yes | 

**Wiki for the Draft Feature:** https://publiclab.org/wiki/draft-feature

**Related issues and PR's:** https://github.com/publiclab/plots2/issues?q=label%3Adraft-feature+is%3Aclosed

### Features

Features, mentioned above, are a type of Node. They are used for things like the front page, banners, footer text, and other content that is more infrastructural but change periodically. They are managed at https://publiclab.org/features.

They are typically cached for quick loading, and can be inserted anywhere in the code to create a semi-permanent dynamic content area like a banner, explanatory text, etc. Here's an example for a Feature with the key `footer-notice`:

```ruby
<% cache('feature_footer-notice', skip_digest: true) do %>
  <%= feature('footer-notice') %>
<% end %>
```


### Revisions

`Revisions` are a child model to Nodes via `nid`, and contain a `title` and `body` field, along with an author as a `uid` field and a `vid` primary key. Revisions have `status` in addition to their parent Node `status`, following the same conventions. Wiki pages default to their latest Revision's `title`.

### Comments

Comments belong to Notes via `nid`, and each have an author via `uid`; primary key `cid`. Maps also have comments via `nid`, and Answers may also have comments, via `aid`.

Comment `status` -- a property of `comments`, can be:

* 0: banned
* 1: normal
* 4: moderated -- i.e. comment created by a first-time poster, and has not yet been "approved"

### Answers

Answers are similar to Comments, but are used in Question-type Notes, and may each have Comments of their own. Primary key `aid`.

****

## Users

Our primary user type is User. Users can login via email using the [Authlogic gem (a simple ruby authentication
solution)](https://github.com/binarylogic/authlogic). Also, recently we have added the option to login via Twitter, Github, Facebook and Google using the
[Omniauth gem](https://github.com/publiclab/plots2/blob/main/doc/Omniauth.md).

Users each have a profile at `/profile/USERNAME`, which displays content stored in the `user.bio` text field.

`user.status` can be:

* 0: banned
* 1: normal
* 5: moderated

User `role` can be:

* `basic`
* `moderator` - ability to spam or unspam content, moderate or ban other users, make others into moderators, and lock pages.
* `admin` - abilities of `moderator`, plus ability to make other admins, delete wiki pages and notes, make Features

****

## Tagging

Tags (`Tag`) are unique tag names with primary key `tid`, which may be linked (by a user) to Nodes via NodeTag (database table `community_tag`) via the latter's `nid` and `tid` fields.
