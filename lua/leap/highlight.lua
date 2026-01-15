-- Code generated from fnl/leap/highlight.fnl - do not edit directly.

local opts = require("leap.opts")
local api = vim.api
local M = {group = {label = "LeapLabel", ["label-dimmed"] = "LeapLabelDimmed", match = "LeapMatch"}, priority = {label = 65535, backdrop = 65534}}
local function __3ergb(n)
  local r = math.floor((n / 65536))
  local g = math.floor(((n / 256) % 256))
  local b = (n % 256)
  return r, g, b
end
local function blend(color1, color2, weight)
  local r1, g1, b1 = __3ergb(color1)
  local r2, g2, b2 = __3ergb(color2)
  local r = ((r1 * (1 - weight)) + (r2 * weight))
  local g = ((g1 * (1 - weight)) + (g2 * weight))
  local b = ((b1 * (1 - weight)) + (b2 * weight))
  return string.format("#%02x%02x%02x", r, g, b)
end
local function dimmed(def_map_2a)
  local def_map = vim.deepcopy(def_map_2a)
  local normal = vim.api.nvim_get_hl(0, {name = "Normal", link = false})
  if (type(normal.bg) == "number") then
    if (type(def_map.bg) == "number") then
      def_map.bg = blend(def_map.bg, normal.bg, 0.7)
    else
    end
    if (type(def_map.fg) == "number") then
      def_map.fg = blend(def_map.fg, normal.bg, 0.5)
    else
    end
  else
  end
  return def_map
end
local function set_label_dimmed()
  local label = vim.api.nvim_get_hl(0, {name = M.group.label, link = false})
  local label_dimmed = dimmed(label)
  return vim.api.nvim_set_hl(0, M.group["label-dimmed"], label_dimmed)
end
local function set_concealed_label_char()
  local label = api.nvim_get_hl(0, {name = M.group.label, link = false})
  local middle_dot = "\194\183"
  opts.concealed_label = ((label.bg and " ") or middle_dot)
  return nil
end
local custom_def_maps = {["leap-label-default-light"] = {fg = "#eef1f0", bg = "#5588aa", bold = true, nocombine = true, ctermfg = "red"}, ["leap-label-default-dark"] = {fg = "black", bg = "#ccff88", nocombine = true, ctermfg = "black", ctermbg = "red"}, ["leap-match-default-light"] = {bg = "#eef1f0", ctermfg = "black", ctermbg = "red"}, ["leap-match-default-dark"] = {fg = "#ccff88", underline = true, nocombine = true, ctermfg = "red"}}
M.init = function(self, force_3f)
  local custom_defaults_3f = ((vim.g.colors_name == "default") or vim.g.vscode)
  local defaults
  local _4_
  if custom_defaults_3f then
    if (vim.o.background == "light") then
      _4_ = custom_def_maps["leap-label-default-light"]
    else
      _4_ = custom_def_maps["leap-label-default-dark"]
    end
  else
    _4_ = {link = "IncSearch"}
  end
  local _7_
  if custom_defaults_3f then
    if (vim.o.background == "light") then
      _7_ = custom_def_maps["leap-match-default-light"]
    else
      _7_ = custom_def_maps["leap-match-default-dark"]
    end
  else
    _7_ = {link = "Search"}
  end
  defaults = {[self.group.label] = _4_, [self.group.match] = _7_}
  for group_name, def_map in pairs(vim.deepcopy(defaults)) do
    if not force_3f then
      def_map.default = true
    else
    end
    api.nvim_set_hl(0, group_name, def_map)
  end
  set_label_dimmed()
  set_concealed_label_char()
  if not vim.tbl_isempty(api.nvim_get_hl(0, {name = "LeapBackdrop"})) then
    if force_3f then
      return vim.api.nvim_set_hl(0, "LeapBackdrop", {link = "None"})
    else
      local user = require("leap.user")
      return user.set_backdrop_highlight("LeapBackdrop")
    end
  else
    return nil
  end
end
return M
