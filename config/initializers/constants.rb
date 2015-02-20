module Callouts
  FINDER = /(^|\W)\@([\w-]+)(\W|$)/
  PRETTYLINKMD = '\1[@\2](/profile/\2)\3'
  PRETTYLINKHTML = '\1<a href="/profile/\2">@\2</a>\3'
end
