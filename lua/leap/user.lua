-- User-space convenience functions that rely only on the public API.

--- Returns a table that can be used as or merged with `opts`,
--- with `keys.next_target` and `keys.prev_target` set appropriately.
local function with_traversal_keys(fwd_key, bwd_key, opts)
   local function with_key(t, key)
      return { type(t) == 'table' and t[1] or t, key }
   end

   local keys = vim.deepcopy(require('leap').opts.keys)

   return vim.tbl_deep_extend('error', opts or {}, {
      keys = {
         next_target = with_key(keys.next_target, fwd_key),
         prev_target = with_key(keys.prev_target, bwd_key)
      }
   })
end

local function set_repeat_keys(fwd_key, bwd_key, kwargs)
   kwargs = kwargs or {}
   local modes = kwargs.modes or { 'n', 'x', 'o' }
   local relative_dir = kwargs.relative_directions

   local function leap_repeat(backward_invoc)
      local leap = require('leap')
      local backward = backward_invoc
      if relative_dir then
         if backward_invoc then
            backward = not leap.state['repeat'].backward
         else
            backward = leap.state['repeat'].backward
         end
      end
      local opts = {
         -- Just overwrite the fields, one wouldn't want to switch to
         -- another key after starting with one.
         keys = vim.tbl_extend('force', leap.opts.keys, {
            next_target = backward_invoc and bwd_key or fwd_key,
            prev_target = backward_invoc and fwd_key or bwd_key,
         })
      }
      leap.leap { ['repeat'] = true, backward = backward, opts = opts }
   end

   vim.keymap.set(modes, fwd_key, function() leap_repeat(false) end, {
      silent = true,
      desc = 'Repeat leap '
         .. (relative_dir and 'in the previous direction' or 'forward')
   })
   vim.keymap.set(modes, bwd_key, function() leap_repeat(true) end, {
      silent = true,
      desc = 'Repeat leap '
         .. (relative_dir and 'in the opposite direction' or 'backward')
   })
end

local function get_enterable_windows()
   return require('leap.util').get_enterable_windows()
end

local function get_focusable_windows()
   return require('leap.util').get_focusable_windows()
end

--- @deprecated
local function add_default_mappings(force)
   for _, t in ipairs {
      { { 'n', 'x', 'o' }, 's',  '<Plug>(leap-forward-to)',    'Leap forward to' },
      { { 'n', 'x', 'o' }, 'S',  '<Plug>(leap-backward-to)',   'Leap backward to' },
      { { 'x', 'o' },      'x',  '<Plug>(leap-forward-till)',  'Leap forward till' },
      { { 'x', 'o' },      'X',  '<Plug>(leap-backward-till)', 'Leap backward till' },
      { { 'n', 'x', 'o' }, 'gs', '<Plug>(leap-from-window)',   'Leap from window' },
      { { 'n', 'x', 'o' }, 'gs', '<Plug>(leap-cross-window)',  'Leap from window' },
   } do
      local modes, lhs, rhs, desc = unpack(t)
      for _, mode in ipairs(modes) do
         -- If not forced, only set the keymaps if:
         -- 1. A keyseq starting with `lhs` is not already mapped to
         --    something else.
         -- 2. There is no existing mapping to the <Plug> key.
         if force or (
            vim.fn.mapcheck(lhs, mode) == '' and vim.fn.hasmapto(rhs, mode) == 0
         ) then
            vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
         end
      end
   end
end

local function setup(user_opts)
   local opts = require('leap.opts').default
   for k, v in pairs(user_opts) do
      opts[k] = v
   end
end

return {
   with_traversal_keys = with_traversal_keys,
   set_repeat_keys = set_repeat_keys,
   get_enterable_windows = get_enterable_windows,
   get_focusable_windows = get_focusable_windows,
   -- deprecated --
   add_repeat_mappings = set_repeat_keys,
   add_default_mappings = add_default_mappings,
   setup = setup,
}
