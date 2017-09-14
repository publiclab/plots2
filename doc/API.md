(Moved from https://github.com/publiclab/plots2/wiki/API/)

Swagger-generated API documentation can be found at:

https://publiclab.org/api/swagger_doc.json

Per-model API endpoints are:

* Profiles: https://publiclab.org/api/srch/profiles?srchString=foo
* Questions: https://publiclab.org/api/srch/questions?srchString=foo
* Tags: https://publiclab.org/api/srch/tags?srchString=foo
* Notes: https://publiclab.org/api/srch/notes?srchString=foo

We also provide RSS feeds for tags and authors, in the format:

* Authors: https://publiclab.org/feed/authorname.rss
* Tagged notes: https://publiclab.org/feed/tag/tagname.rss
* Main feed: https://publiclab.org/feed.rss

Tag-based listings can also be requested in JSON and XML formats:

* Notes by tag in JSON: https://publiclab.org/tag/balloon-mapping.json
* Wikis by tag in XML: https://publiclab.org/wiki/tag/place:*.xml
* Questions by tag in JSON: https://publiclab.org/questions/tag/spectrometry.json
* Maps by tag in XML: https://publiclab.org/maps/tag/gulf-coast.xml

To these last, you can do wildcard tag searches using the `*` character, like this:

* https://publiclab.org/tag/event:*.json
