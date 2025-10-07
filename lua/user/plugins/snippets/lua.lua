local snippets = require('user.plugins.snippets')
local format = snippets.format

snippets.set_snippets('lua', {
    ['r'] = "require('$1')",
    ['pr'] = 'print($1)',
    ['lv'] = 'local ${1:name} = ${2:value}',
    ['fn'] = 'function($1) ${2} end',
    ['fnn'] = format [[
      ${1:local }function ${2:name}(${3:params})
      \t$0
      end
    ]],
    ['if'] = format [[
      if $1 then
      \t$0
      end
    ]],
    ['ife'] = format [[
      if $1 then
      \t$2
      else
      \t$0
      end
    ]],
    ['for'] = format [[
      for ${1:i} = ${2:1}, ${3:10}, ${4:1} do
      \t$0
      end
    ]],
    ['fore'] = format [[
      for ${1:index}, ${2:value} in ${3:i}pairs($4) do
      \t$0
      end
    ]],
    ['whi'] = format [[
      while ${1:true} do
      \t$0
      end
    ]],
})
