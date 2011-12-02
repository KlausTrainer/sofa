function(head, req) {
  start({"code": 302, "headers": {"Location": "/blog/_design/sofa/_list/index/recent-posts?descending=true&limit=10"}});
}