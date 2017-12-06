module Callouts
  FINDER = /([^`\w]|^)\@([\w-]+)/
  HASHTAG = /(\s)\#([:a-zA-Z0-9_-]+)/
  PRETTYLINKMD = '\1[@\2](/profile/\2)'
  HASHLINKMD = '\1[#\2](/tag/\2)'
  HASHTAGNUMBER = /(\s)\#([:0-9]+)/
  NODELINKMD = '\1[#\2](/n/\2)'
  PRETTYLINKHTML = '\1<a href="/profile/\2">@\2</a>'
  HASHLINKHTML = '\1<a href="/tag/\2">#\2</a>'
  NODELINKHTML = '\1<a href="/n/\2">#\2</a>'
end
