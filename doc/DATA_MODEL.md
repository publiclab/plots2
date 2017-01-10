PublicLab.org's Data Model
======

_This page attempts to explain the database model for the plots2 project._

The following diagram is a rough sketch of how the applications various tables interconnect:

![data model diagram](https://publiclab.org/system/images/photos/000/019/147/original/scratchpad.png)

****

## Content

All user-generated content on PublicLab.org is either a Node, an Answer, or a Comment. 

### Nodes

Nodes are a general type with primary key `nid`, a `title`, an author `uid`, and a `path`, or relative URL starting with "/".

There are several types of nodes, based on their `type` field:

* Notes, or research notes, of type "note", are single-author, single-revision. 
* Wikis, or wiki pages, of type "page", have many revisions, each of which has an author. They have a path like `/wiki/title` or simply `/title` (for so-called "root" pages). 
* Features, of type "feature", are blocks of content which can be included (hard-coded) throughout the site, but can only be made by admins. They are used for things like the front page, banners, and other content that is more infrastructural but change periodically. They are managed at https://publiclab.org/features.
* Maps, of type "map", are web-map image layers and associated image files, displayed on https://publiclab.org/archive

Nodes may also be redirects, though this use is legacy only. More documentation needed.

Nodes also have a Counter (DrupalNodeCounter) child model which tracks pageviews. 

Notes (type `note`) can also be a sub-type called Questions, if they have a tag starting with `question:` -- which gives them extra features such as the ability to have Answers (see below).


### Revisions

Revisions, or `DrupalNodeRevisions`, are a child model to Nodes via `nid`, and contain a `title` and `body` field, along with an author as a `uid` field and a `vid` primary key. Revisions have `status` in addition to their parent Node `status`, following the same conventions. Wiki pages default to their latest Revision's `title`.

### Comments

Comments belong to Notes via `nid`, and each have an author via `uid`; primary key `cid`. Maps also have comments via `nid`, and Answers may also have comments, via `aid`.

### Answers

Answers are similar to Comments, but are used in Question-type Notes, and may each have Comments of their own. Primary key `aid`.

****

## Users

Our primary user type is User, an Authlogic model. We also maintain a legacy `DrupalUsers` type, but are in the process of deprecating it. Users and `DrupalUsers` both have `uid` fields, which are synced one-to-one, and to fully deprecate `DrupalUsers` we must migrate these fields over to User.

Users each have a profile at `/profile/username`, which displays content stored in an assocaited `DrupalProfileValue` with `fid = 7`.

User `status` -- a property of `DrupalUser`, can be:

* 0: banned
* 1: normal
* 5: moderated

User `role` can be:

* `basic`
* `moderator` - ability to spam or unspam content, moderate or ban other users, make others into moderators, and lock pages.
* `admin` - abilities of `moderator`, plus ability to make other admins, delete wiki pages and notes, make Features

****

## Tagging

Tags (`Tag`) are unique tag names with primary key `tid`, which may be linked to Nodes via join table CommunityTag (`DrupalNodeCommunityTag`) via the latter's `nid` and `tid` fields.


