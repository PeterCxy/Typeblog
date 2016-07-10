data = require './from.json'
posts = data.db[0].data.posts
fs = require 'fs'
moment = require 'moment'

fs.mkdirSync './out'
arr = []
posts.forEach (post) ->
  result = {}
  result.title = post.title
  result.url = post.slug
  result.date = moment(post.created_at).format 'YYYY-MM-DD'
  result.parser = "Markdown"

  content = """
```json
#{JSON.stringify result, null, 2}
```

#{post.markdown}
"""
  fs.writeFileSync "./out/#{post.slug}.md", content

  if post.published_at?
    arr.unshift "posts/#{post.slug}.md"

fs.writeFileSync "./out/list.json", JSON.stringify arr, null, 2