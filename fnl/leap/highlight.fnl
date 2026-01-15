(local opts (require "leap.opts"))

(local api vim.api)


(local M {:group {:label "LeapLabel"
                  :label-dimmed "LeapLabelDimmed"
                  :match "LeapMatch"}
          :priority {:label 65535
                     :backdrop 65534}})


(fn ->rgb [n]  ; n=(r+g+b), as returned by `nvim_get_hl`
  (let [r (math.floor (/ n 0x10000))
        g (math.floor (% (/ n 0x100) 0x100))
        b (% n 0x100)]
    (values r g b)))


(fn blend [color1 color2 weight]
  (let [(r1 g1 b1) (->rgb color1)
        (r2 g2 b2) (->rgb color2)
        r (+ (* r1 (- 1 weight)) (* r2 weight))
        g (+ (* g1 (- 1 weight)) (* g2 weight))
        b (+ (* b1 (- 1 weight)) (* b2 weight))]
    (string.format "#%02x%02x%02x" r g b)))


(fn dimmed [def-map*]
  (local def-map (vim.deepcopy def-map*))
  (local normal (vim.api.nvim_get_hl 0 {:name "Normal" :link false}))
  ; `bg` can be nil (transparent background), and e.g. the old default
  ; color scheme (`vim`) does not define Normal at all.
  ; Also, `nvim_get_hl()` apparently does not guarantee to return
  ; numeric values in the table (#260).
  (when (= (type normal.bg) "number")
    (when (= (type def-map.bg) "number")
      (set def-map.bg (blend def-map.bg normal.bg 0.7)))
    (when (= (type def-map.fg) "number")
      (set def-map.fg (blend def-map.fg normal.bg 0.5))))
  def-map)


(fn set-label-dimmed []
  (let [label (vim.api.nvim_get_hl 0 {:name M.group.label :link false})
        label-dimmed (dimmed label)]
    (vim.api.nvim_set_hl 0 M.group.label-dimmed label-dimmed)))


(fn set-concealed-label-char []
  (let [label (api.nvim_get_hl 0 {:name M.group.label :link false})
        middle-dot "\u{00b7}"]
    ; Undocumented option, might be exposed in the future.
    (set opts.concealed_label (or (and label.bg " ") middle-dot))))


(local custom-def-maps
  {:leap-label-default-light {:fg "#eef1f0"  ; NvimLightGrey1
                              :bg "#5588aa"
                              :bold true
                              :nocombine true
                              :ctermfg "red"}
   :leap-label-default-dark  {:fg "black"
                              :bg "#ccff88"
                              :nocombine true
                              :ctermfg "black"
                              :ctermbg "red"}
   :leap-match-default-light {:bg "#eef1f0"  ; NvimLightGrey1
                              :ctermfg "black"
                              :ctermbg "red"}
   :leap-match-default-dark {:fg "#ccff88"
                             :underline true
                             :nocombine true
                             :ctermfg "red"}})


(fn M.init [self force?]
  (let [custom-defaults? (or (= vim.g.colors_name "default")
                             ; vscode-neovim has a problem with
                             ; linking to built-in groups.
                             vim.g.vscode)
        defaults {self.group.label
                  (if custom-defaults?
                      (if (= vim.o.background "light")
                          custom-def-maps.leap-label-default-light
                          custom-def-maps.leap-label-default-dark)
                      {:link "IncSearch"})

                  self.group.match
                  (if custom-defaults?
                      (if (= vim.o.background "light")
                          custom-def-maps.leap-match-default-light
                          custom-def-maps.leap-match-default-dark)
                      {:link "Search"})}]
    (each [group-name def-map (pairs (vim.deepcopy defaults))]
      (when (not force?)
        ; Set only as the default (fallback). (:h hi-default)
        (set def-map.default true))
      (api.nvim_set_hl 0 group-name def-map))
    ; These should be done last, based on the actual group definitions.
    (set-label-dimmed)
    (set-concealed-label-char)

    ; Handle `LeapBackdrop` (deprecated).
    (when (not (vim.tbl_isempty (api.nvim_get_hl 0 {:name "LeapBackdrop"})))
      (if force?
          (vim.api.nvim_set_hl 0 "LeapBackdrop" {:link "None"})
          (let [user (require "leap.user")]
            (user.set_backdrop_highlight "LeapBackdrop"))))))

M
