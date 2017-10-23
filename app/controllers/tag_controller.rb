<%= render :partial => "sidebar/featured" %>

<div class="col-md-9">
  <table style="width:100%">
    <tr>
     <th style="width: 50% ;">
       <h1 style="font-family:Junction Light;"><%= t('tag.index.popular_tags') %></h1>
     </th>
     <th style="width: 50% ; text-align: right ;">
      

      <a class="btn btn-default" rel="popover" data-trigger="focus" data-placement="bottom" data-html="true" data-content=" <a href = <%= tags_path(1) %> >Number of uses</a> <br> <a href = <%= tags_path(2) %> >Alphabetically</a>">
        <i class="fa fa-sort"></i> <%=t('tag.index.sort_by') %>
      </a>
    
     </th>
   </tr>
 </table>
  <p><%= t('tag.index.browse_popular_tags') %></p>
  <!-- Search Bar -->
    <input type="text" id="myInput"  placeholder="Search for tags..">
    <script>
      $('#myInput').keypress(function (e) {
           var key = e.which;
           if(key == 13)  // the enter key code
            {
             var pre = document.getElementsByTagName("input")[1].value ;

              window.location.href = " <%= tags_path %>"+"/"+pre  
            }
          });   
    </script>
    <br><br>

  <table class="table">
    <tr>
      <th><%= t('tag.index.tag') %></th>
      <th><%= t('tag.index.number_of_uses') %></th>
      <th><%= t('tag.index.number_of_subscriptions')%></th>
      <% if current_user %>
        <th><%= t('tag.index.subscriptions') %></th>
      <% end %>
    </tr>
    <% @tags.each do |tag| %>
      <tr>
        <td><i class="fa fa-tag"></i> <a href="/tag/<%= tag.name %>"><%= tag.name %></a></td>
        <td><%= tag.count %></td>
        <td><a class="btn btn-default btn-sm" rel="popover" data-placement="right" data-html="true" data-title="<%= t('tag.show.users_following_tag') %>" data-content="<% Tag.followers(tag.name).each do |user| %><i class='fa fa-star-o'></i> <a href='/profile/<%= user.username %>'><%= user.username %></a><br /><% end %><% if Tag.follower_count(tag.name) == 0 %><i><%= t('tag.show.none') %></i><% end %>"><%= Tag.follower_count(tag.name) %> <i class="fa fa-user"></i> <span class="caret"></span></a></td>
        <script type="text/javascript">
          //show one popover at a time
          $('.btn').on('click', function (e) {
              $('.btn').not(this).popover('hide');
          });
        </script>
        <% if current_user %>
          <td>
             <% if current_user.following(tag.name) %>
                <a rel="tooltip" title="<%= t('tag.show.unfollow') %>" class="btn btn-default btn-sm active" href="/unsubscribe/tag/<%= tag.name %>"><i class="fa fa-eye"></i> <%= t('tag.show.following') %></a>
                <% else %>
                <a class="btn btn-default btn-sm" href="/subscribe/tag/<%= tag.name %>"><i class="fa fa-eye"></i> <%= t('tag.show.follow') %></a>
                <% end %>
          </td>
        <% end %>
      </tr>
    <% end %>
  </table>
  <%= will_paginate @tags, :renderer => BootstrapPagination::Rails if @paginated %>

  <hr />
  
</div>
