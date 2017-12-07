module Callouts
  FINDER = /([^`\w]|^)\@([\w-]+)/
  HASHTAG = /(\s)\#([:a-zA-Z0-9_-]+)/
  PRETTYLINKMD = '\1[@\2](/profile/\2)'
  HASHLINKMD = '\1[#\2](/tag/\2)'
  PRETTYLINKHTML = '\1<a href="/profile/\2">@\2</a>'
  HASHLINKHTML = '\1<a href="/tag/\2">#\2</a>'
end
