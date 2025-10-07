local snippets = require('user.plugins.snippets')

snippets.set_snippets('html', {
  ['(%w+)t'] = function(_, tagname)
    return string.format('<%s$1>$2</%s>', tagname, tagname)
  end,
})
