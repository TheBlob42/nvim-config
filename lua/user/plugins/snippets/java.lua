local snippets = require('user.plugins.snippets')
local format = snippets.format

snippets.set_snippets('java', {
    ['syso'] = 'System.out.println($1);',
    ['pa'] = function()
      local path = vim.fn.expand('%:p:h')
        :gsub('^.*src/.*/java/', '')
        :gsub('/', '.')
      return 'package ' .. path .. ';'
    end,
    ['class'] = function()
      local name = vim.fn.expand('%:t:r')
      return format([[
        public class %s {
        \t$0
        }
      ]], name)
    end,
    ['cons'] = function()
      local t = require('user.plugins.treesitter')
      local node = t.find_node(function(n)
        return vim.tbl_contains({ 'class_declaration', 'record_declaration' }, n:type())
      end, 'upward')

      if node then
        local name = vim.treesitter.get_node_text(node:field('name')[1], 0)
        return format([[
          ${1|public ,private ,protected |}%s($2) {
          \t$0
          }
        ]], name)
      end

      return ''
    end,
    ['if'] = format [[
      if ($1) {
      \t$0
      }
    ]],
    ['ife'] = format [[
      if ($1) {
      \t$2
      } else {
      \t$0
      }
    ]],
    ['for'] = format [[
      for (int ${1:i=0}; ${2:i<0}; ${3:i++}) {
      \t$0
      }
    ]],
    ['fore'] = format [[
      for (${1:var} ${2:name} : ${3:coll}) {
      \t$0
      }
    ]],
    ['whi'] = format [[
      while (${1:true}) {
      \t$0
      }
    ]],
    ['m'] = format [[
      ${1|public ,private ,protected |}${2:static }${3:void} ${4:name}($5) {
      \t$0
      }
    ]],
    ['jd'] = function() -- "jd" for Javadoc
      local t = require('user.plugins.treesitter')
      local pos = vim.api.nvim_win_get_cursor(0)
      local node = assert(t.get_node({ biggest = true, pos = { pos[1], pos[2] }}))
      local type = node:type()

      local snippet = ''
      if type == 'method_declaration' then
        local query_results = t.get_captures(
          node,
          vim.treesitter.query.parse('java', [[
            (method_declaration
              type: (_) @type
              parameters: (formal_parameters
                            (formal_parameter
                              name: (identifier) @name)))]]))
        snippet = '/**\n * $1'
        local params = query_results['name']
        for i, p in ipairs(params) do
            snippet = snippet .. '\n * @param ' .. p .. ' $' ..(i+2)
        end
        if query_results['type'][1] ~= 'void' then
            snippet = snippet .. '\n * @return $'..(vim.tbl_count(params) + 3)
        end
        snippet = snippet .. '\n */$0'
      elseif type == 'constructor_declaration' then
        local query_results = t.get_captures(
          node,
          vim.treesitter.query.parse('java', [[
            (constructor_declaration
              parameters: (formal_parameters
                            (formal_parameter
                              name: (identifier) @name)))]]))
        snippet = '/**\n * $1'
        local params = query_results['name'] or {}
        for i, p in ipairs(params) do
          snippet = snippet .. '\n * @param ' .. p .. ' $' .. (i+2)
        end
        snippet = snippet .. '\n */$0'
      elseif vim.endswith(type, '_declaration') then
        snippet = format [[
          /**
           * $0
           */
        ]]
      else
        snippet = format [[
          /*
           * $0
           */
        ]]
      end
      return snippet
    end,
})
