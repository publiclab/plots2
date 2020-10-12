(Moved from https://github.com/publiclab/plots2/wiki/API/)

# Swagger API

Our Swagger-generated API is quite extensive and growing. It can be easily accessed
on the [web interface](https://publiclab.org/api/docs) and on the [json guide](https://publiclab.org/api/swagger_doc.json).

## Endpoints

To add any additional parameter, you can add the `&` symbol followed by the field to the URL:

`https://publiclab.org/api/srch/profiles?query=bob&limit=10`

where `limit` is an optional parameter.

All the endpoints have the optional parameter `limit` (10 by default) where you can specify the number of results for your search. Below you have a description of the available endpoints.

### All (profiles, notes, tags, maps, etc.)

* **URL**:  `https://publiclab.org/api/srch/all?query=bob`

* **URL Params** :

  **Required:**

  `query=[string]`: search for notes, profiles, tags, questions and maps that match the query.

### Profiles:

* **URL**:  `https://publiclab.org/api/srch/profiles?query=bob`

* **URL Params** :

  **Required:**

  `query=[string]`: Search the profiles (users) that have the query on their `username` and `bio` profile info.

  **Optional:**

  `sort_by=[string]`: Sort the profiles by the most recent activity. If no value
   provided, the results are then sorted by user id (desc).

  `order_direction=[string]`: It accepts `ASC` or `DESC` (the latter is the default).

  `field=[string]`: Accepts the value `username` for searching profiles only by
   the field `username`. And accepts the value `tag` for searching profiles by tag.

### Notes

* **URL**:  `https://publiclab.org/api/srch/notes?query=wind`
* **URL Params** :

 **Required:**

 `query=[string]`: Search for notes that have the passed string on their content.

### Wikis

 * **URL**:  `https://publiclab.org/api/srch/wikis?query=balloon`
 * **URL Params** :

  **Required:**

  `query=[string]`: Search for wikis that have the passed string on their content.

### Questions

* **URL**:  `https://publiclab.org/api/srch/questions?query=arduino`
* **URL Params** :

  **Required:**

  `query=[string]`: Search for notes that have the `question:query` on their tags list.

### Tags

* **URL**:  `https://publiclab.org/api/srch/tags?query=wind`
* **URL Params** :

  **Required:**

  `query=[string]`: Search the notes that have the query on their tags list.

### TagLocations:

* **URL**:  `https://publiclab.org/api/srch/taglocations?nwlat=200.0&selat=0.0&nwlng=0.0&selng=200.0`
* **URL Params** :

  **Required:**

  `nwlat=[northwest latitude],selat=[southeast latitude],nwlng=[northwest longitude],selng=[southeast longitude]`: Search notes within the rectangle boundary made by these diagonally opposite coordinates.

  **Optional:**

  `tag=[string]`: The search can be refined by passing a tag field.

  `order_direction=[string]`: It accepts `ASC` or `DESC` (the latter is the default).

  `sort_by=[string]`: It accepts `recent`. It sorts the nodes by the most recent activity. If no value
     provided, the results are then sorted by node creation (desc).

   `from=[date]`: It accepts a date, if not specified (1990,01,01). It searches for nodes created from the date.

   `to=[date]`: Accepts a date, if not specified uses `now`. It searches for nodes created by the specified date.

### NearbyPeople:

* **URL**:  `https://publiclab.org/api/srch/nearbyPeople?nwlat=200.0&selat=0.0&nwlng=0.0&selng=200.0`
* **URL Params** :

  **Required:**

  `nwlat=[northwest latitude],selat=[southeast latitude],nwlng=[northwest longitude],selng=[southeast longitude]`: Search users within the rectangle boundary made by these diagonally opposite coordinates.

  **Optional:**

  `tag=[string]`: The search can be refined by passing a user tag field.

  `field=[string]`: Accepts the value `node_tag` for searching users following the node tag (topic). When the endpoint receives a `tag` as parameter by default it searches users with the specified user tag, this parameter switches the use of the tag parameter to link node tags instead.

  `order_direction=[string]`: It accepts `ASC` or `DESC` (the latter is the default).

  `sort_by=[string]`: It accepts `recent` and `content`. Sort the profiles by the most recent activity or most nodes created. If no value provided, the results are then sorted by signup date (desc).

  `from=[date]`: It accepts a date. It searches for users with some activity from the specified date.

  `to=[date]`: Accepts a date. It searches for users with some activity by the specified date.

## API code

We are beginning to consolidate API methods into the [srch](https://github.com/publiclab/plots2/blob/main/app/api/srch) namespace, to reduce complexity in the non-API codebase and make the API more predictable and maintainable.

API methods are found on the [Search class](https://github.com/publiclab/plots2/blob/main/app/api/srch/search.rb). This Search class is responsible to package the results into a [DocResult](https://github.com/publiclab/plots2/blob/main/app/models/doc_result.rb).

We also have 3 services that aim to maintain the code more easier to change/maintain:

* [ExecuteSearch](https://github.com/publiclab/plots2/blob/main/app/services/execute_search.rb): responsible to execute the requested endpoint from the params.

* [SearchCriteria](https://github.com/publiclab/plots2/blob/main/app/services/search_criteria.rb): responsible to validate the params.

* [SearchService](https://github.com/publiclab/plots2/blob/main/app/services/search_service.rb): responsible to perform the endpoints queries.

We also have a [Planning Issue](https://github.com/publiclab/plots2/issues/3520) if you want to contribute to the API.

## Token based API for creating comment

This feature allows a logged user or bot to post comments via API with a token. You can generate your token to use this feature accessing your Profile on https://publiclab.org/profile/your-username (just make sure you are logged in).

This API method can be found [here](https://github.com/publiclab/plots2/blob/main/app/controllers/comment_controller.rb#L48-L73). You can see how to use this below:

* **URL**:  `/comment/create/token/id.:format`
* **Method:**   `POST`
* **URL Params** :

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

****

# Legacy API

### RSS feeds

RSS feeds can be found [here](https://github.com/publiclab/plots2/blob/main/app/views/tag/rss.rss.builder).

* Authors: https://publiclab.org/feed/authorname.rss
* Tagged notes: https://publiclab.org/feed/tag/tagname.rss
* Main feed: https://publiclab.org/feed.rss

### JSON and XML formats

Tag-based listings can also be requested in JSON and XML formats:

* Notes by tag in JSON: https://publiclab.org/tag/balloon-mapping.json
* Wikis by tag in XML: https://publiclab.org/wiki/tag/place:*.xml
* Questions by tag in JSON: https://publiclab.org/questions/tag/spectrometry.json
* Maps by tag in XML: https://publiclab.org/maps/tag/gulf-coast.xml

To these last, you can do a wildcard tag search using the `*` character, like this:

* https://publiclab.org/tag/event:*.json

Several tag-based JSON/XML listings are generated [directly from controllers](https://github.com/publiclab/plots2/blob/main/app/controllers/tag_controller.rb#L97-L108), as alternate responses to various requests, ending in `.json` or `.xml`.
