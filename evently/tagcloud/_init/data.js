function(resp) {
  var app = $$(this).app
  var path = app.require("vendor/couchapp/lib/path").init(app.req)
  var tags = []
  maxcount = 1
  mincount = 1
  resp.rows.forEach(function(r) {
    var tag = r.key[0]
    maxcount = Math.max(r.value, maxcount)
    mincount = Math.min(r.value, mincount)
    var link = path.list("index","tags", {
      descending : true, 
      reduce : false,
      limit : 10,
      startkey : [tag, {}], 
      endkey : [tag]})
    tags.push({
      tag : tag,
      link : link,
      size : r.value
    })
  })
  distribution = (maxcount - mincount) / 6
  for (i = 0; i < tags.length; i++) {
    tag = tags[i]
    tag.tagClass = "mediumTag"
    if (tag.size == maxcount)
      tag.tagClass = "mostHugeTag"
    else if (tag.size > mincount + (distribution * 5))
      tag.tagClass = "hugestTag"
    else if (tag.size > mincount + (distribution * 4))
      tag.tagClass = "hugeTag"
    else if (tag.size > mincount + (distribution * 3))
      tag.tagClass = "biggestTag"
    else if (tag.size > mincount + (distribution * 2))
      tag.tagClass = "bigTag"
    else if (tag.size > mincount + distribution)
      tag.tagClass = "mediumTag"
    else if (tag.size > mincount)
      tag.tagClass = "smallTag"
    else if (tag.size == mincount)
      tag.tagClass = "smallestTag"
  }
  return {tags: tags}
}