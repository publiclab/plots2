(Moved from https://github.com/publiclab/plots2/wiki/API/)

## Swagger API

Our Swagger-generated API is quite extensive and growing:

### Web interface/guide

https://publiclab.org/api/docs

https://publiclab.org/api/swagger_doc.json

Per-model API endpoints are:

* Profiles: https://publiclab.org/api/srch/profiles?srchString=foo
* Questions: https://publiclab.org/api/srch/questions?srchString=foo
* Tags: https://publiclab.org/api/srch/tags?srchString=foo
* Notes: https://publiclab.org/api/srch/notes?srchString=foo
* Locations: https://publiclab.org/api/srch/locations?srchString=lat,lon
* PeopleLocations: https://publiclab.org/api/srch/peoplelocations?srchString=QRY

****

## Legacy API

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

## API code

API methods are found in the codebase in the following places:

* https://github.com/publiclab/plots2/blob/master/app/api/srch/typeahead.rb
* https://github.com/publiclab/plots2/blob/master/app/api/srch/search.rb

We are beginning to consolidate API methods into the `/app/api/srch/` namespace, to reduce complexity in the non-API codebase and make the API more predictable and maintainable. 

RSS feeds can be found in views, such as:

https://github.com/publiclab/plots2/blob/master/app/views/tag/rss.rss.builder

And several tag-based JSON/XML listings are generated directly from controllers, as alternate responses to various requests, ending in `.json` or `.xml`:

https://github.com/publiclab/plots2/blob/master/app/controllers/tag_controller.rb#L97-L108

