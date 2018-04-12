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

## Token based API for creating comment
Allows a logged user or bot to post comments via API with a token.

API method is found in the codebase in the following place:

https://github.com/publiclab/plots2/blob/master/app/controllers/comment_controller.rb#L48-L73

* **URL**:  `/comment/create/token/id.:format`
* **Method:**   `POST`
* **URL Params** :-

   **Required:**

   `id=[integer]`: This value specifies the node for which comment is to be created
   
   `format=[string]` : Specifies response format 
   
   `username=[string]`: This string specifies username of user tends to create comment by this API post request
 
   **Data Params:** 
   
    `body=[string]` : This is the actual content of the comment.
 
   **Headers:** 

   `TOKEN=[string]`: This string value specifies ``access_token`` of the user for authentication purpose.

* **Success Response:**
  * **Code:** 201 Created <br>
    **Content:** None

* **Error Response:**
  * **Code:** 400 BAD REQUEST <br>
    **Content:** None

* **Sample Call:**
  ```
  POST https://publiclab.org/comment/create/token/id.json

  Headers:-
  "HTTP_TOKEN": "7a969e3d-cfe1-4da5-9b4c-71a42c9eef88"

  Body:
  {
    "username": "user",
    "body": "This is a comment made with a token"
  }
  ```