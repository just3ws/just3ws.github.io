---
layout: post
title: Using Postgres RegEx Expressions to Find Very Specific Matches
date: 2015-02-25
tags: [PostgreSQL, RegEx, Ruby on Rails, SQL]
archive_note: This post was written in 2015 while working at Coderwall and migrated from an earlier blog. The Ruby and PostgreSQL techniques described remain applicable.
---

Coderwall has been having issues with certain avatars generating 403 errors in
the browser console. You probably wouldn't notice unless you had your dev tools
open while you were browsing but there were a little over 25% of our Twitter
avatars that weren't rendering properly due to trying to connect via HTTP
instead of HTTPS. (_And other changes to how Twitter resolves it's profile
images but that's a bigger issue._) Fortunately with the power of Ruby and
Postgres RegEx selectors it's relatively trivial to find and transform the HTTP
urls to use HTTPS.

```ruby
User.where("twitter_token is not null AND thumbnail_url ~ '^https:' AND thumbnail_url ~ 'twimg\.com'").find_each(batch_size: 500) do |user|
  begin
    url = URI.parse(user.profile_url)
    puts "Update #{user.username} because #{user.profile_url} appears to be HTTP."
    url.scheme = 'https'
    user.update_attribute(:thumbnail_url, url.to_s)
    puts " ==> #{user.profile_url}"
  rescue URI::InvalidURIError
    ap url
  end
end
```

Our `User` model has a field `thumbnail_url` which holds the URL for users who
log into Coderwall via OAuth. Since the issue was currently a problem
predominantly for Twitter logins, and LinkedIn doesn't allow for fetching the
thumbnails via HTTPS, I first limited the query to known Twitter login users.

Next I want to filter by users who have `thumbnail_url`'s that are not already
using HTTPS. That number was near-zero after some poking I did to verify the
issue, but better to be safe than sorry and it also helps with re-running the
script, no sense in selecting a record that's already been updated. I used the
Postgres RegEx matcher `thumbnail_url ~ '^https:'` but could very well have used
`thumbnail_url ilike 'https:%'` which can still utilize some indexes if
available. The `ilike` vs `like` is also preferable in this case because it is
case-insensitive

The last part of the query `thumbnail_url ~ 'twimg\.com'` could have also been
`thumbnail_url ilike '%twimg.com%'` but was used because I was refactoring from
matchers that were inside the block as I was testing this little bit of
functionality.

Then I used the `find_each(batch_size: 500)` to fetch the records in batches of
500 to avoid excessive queries. Given this batch size I did about 56+ `select`s
instead of 28,000+.

We can fetch Avatars from a few different places so we abstract the url via the
`profile_url` method. I could have just fetched from `thumbnail_url` but it
didn't make any difference in this case. I load the url into `URI.parse` so I
can manipulate the url without string manipulation. I convert the `scheme` on
the URI instance and then update the attribute on the model. The `puts` and `ap`
(awesome_print) statements are just there to help me as I watch the process run.

While the query could have further been simplified via `ilike` wildcard
statements the Postgres RegEx expressions are very useful for matching data
inside a Postgres instance and let you have extremely fine grained control over
the your results without having to pull more than you absolutely must from the
database. They come at a cost of being rather non-index friendly but they are a
useful tool to have at your disposal when you need it.
