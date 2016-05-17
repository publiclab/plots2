module Callouts
  FINDER = /(^|\W)\@([\w-]+)/
  HASHTAG = /(\s)\#([\w-]+)/
  PRETTYLINKMD = '\1[@\2](/profile/\2)'
  HASHLINKMD = '\1[#\2](/tag/\2)'
  PRETTYLINKHTML = '\1<a href="/profile/\2">@\2</a>'
  HASHLINKHTML = '\1<a href="/tag/\2">#\2</a>'
end
