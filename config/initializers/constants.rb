module Callouts
  FINDER = /[\u2022,\u2023,\u25E6,\u2043,\u2219]?(^|\s)\@([\w-]+)/ 
  HASHTAG = /(\s)\#([:a-zA-Z0-9_-]+)/
  PRETTYLINKMD = '\1[@\2](/profile/\2)'
  HASHLINKMD = '\1[#\2](/tag/\2)'
  PRETTYLINKHTML = '\1<a href="/profile/\2">@\2</a>'
  HASHLINKHTML = '\1<a href="/tag/\2">#\2</a>'
end
