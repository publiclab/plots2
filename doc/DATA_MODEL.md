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

These are the basic user statuses. However, being a "first timer" for commenting or node posting is calculated on the fly here, rather than being stored as a state: https://github.com/publiclab/plots2/blob/main/app/models/user.rb#L227-L233 (see `first_time_poster` and `first_time_commenter`)

User `role` can be:

* `basic`
* `moderator` - ability to spam or unspam content, moderate or ban other users, make others into moderators, and lock pages.
* `admin` - abilities of `moderator`, plus ability to make other admins, delete wiki pages and notes, make Features

****

## Tagging

We use 2 types of tags to organize and interconnect content and users across PublicLab.org: "node tags" or "Tags" and "profile tags". 

### Tagging content

The most widely used system is Tags, which is where pages (nodes, such as wikis or notes or questions) have been tagged by users with topic-specific words like `water-quality`. Each page may have many tags, and each tag also has its own page, such as https://publiclab.org/tag/water-quality, listing all the pages using that tag. When a page is tagged, we record who tagged it and when.

How this works technically:

* The `Tag` [model](https://github.com/publiclab/plots2/blob/main/app/models/tag.rb) has 1 entry for each unique tagname (`tag.name`), such as `water-quality`. 
* `Tag` entries are linked with the many nodes (note, wiki, etc) which are "tagged" with this tagname, with the model `NodeTag` (which, for Drupal legacy reasons uses the table `community_tags`) - that is, `tag.nid = node_tag.nid`
* `NodeTag` [entries](https://github.com/publiclab/plots2/blob/main/app/models/node_tag.rb) also have a timestamp, and a user, `node_tag.user`, which is the person who applied the tag to the node.

Some tags activate additional functions; these are known as Power Tags, and are documented at https://publiclab.org/power-tags

### Following tags

Tags have come to define "topical interest groups" - like forums - both collecting topically related content (pages, notes, questions) and also allowing users to "follow" (i.e. subscribe or join, although we stylistically prefer "follow" as a verb) topical content. To post content with tags does not currently mean you automatically follow (join) that topic, but we are considering changing this (May '22). You can manage the tags you follow on the Subscriptions page, at https://publiclab.org/subscriptions

In general, the site has evolved to be more of a collection of distinct (though interlinked) topical groups, rather than a mixed collection of content and people. Each tag is intended to be a sub-community dedicated to a specific topic. 

**Followers vs. contributors:** Followers of a tag ([see code](https://github.com/publiclab/plots2/blob/9cedf36fc20de1c8982885d8ca73338214c3fa57/app/models/tag.rb#L164-L171)) are listed on the tag page alongside "contributors," which are people who have _posted wikis or notes tagged with a given tagname, edited wikis or commented on pages with a given tagname_ ([see code](https://github.com/publiclab/plots2/blob/9cedf36fc20de1c8982885d8ca73338214c3fa57/app/models/tag.rb#L64-L78)). See https://publiclab.org/contributors/water-quality for example. 

**Notifications:** When you follow tags, you begin getting email notifications when content is posted bearing that tag. If a page is newly tagged with a tag you follow, you also get an email notification unless you have already received one for a prior tag which you are following and which already existed on that page. You can adjust your notification preferences at https://publiclab.org/settings

How this works technically:

* The `TagSelection` [model](https://github.com/publiclab/plots2/blob/main/app/models/tag_selection.rb) links `Tag` records with `User` [records](https://github.com/publiclab/plots2/blob/main/app/models/user.rb) when a user follows a tag. 

### Profile tags

Profile Tags (Rails model `UserTag`) are a completely separate system from Tags, though they are structured similarly. Instead of applying tags to content, Profile Tags are applied to user accounts, and appear on users' profiles. They do not reference nodes (wikis, notes, questions) at all. They have a more limited, infrastructural use and are more rarely used in practice, but these uses include:

* adding a location to your profile with `lat:41`, `lon:-71`, and `zoom:6` style tags, subject to location privacy tag `location:blurred`; [read more here](https://publiclab.org/location-privacy)
* determining membership in a "group" -- such as moderators, or educators. This is an old and not much used system; [read more here](https://publiclab.org/wiki/power-tags#Inline+People+Lists).
* opting into the Translation group (with tag `translation-helper`), which activates translation helpers across the site to crowdsource translation of the site's interfaces
* adjusting notification preferences; note that these are generated automatically through https://publiclab.org/settings. They include:
    * whether you receive email (`notifications:noemail`)
    * what types of events trigger notifications (`notifications:like`, `notifications:mentioned`)
    * whether you receive notifications for the moderation system (`no-moderation-emails`)
    * whether you receive a weekly digest of spam posts (`digest:weekly:spam`)
* your OAuth login methods (`oauth:twitter`), such as "log in with Google/Facebook/Twitter" - these cannot be added manually, but only through the login process

As suggested from the above list, some profile tags generate additional features, similarly to Power Tags (see above). 

Note that adding a profile tag such as `water-quality` would have no relation or effect on membership or subscription to the `water-quality` tag, as the systems are separate. 
