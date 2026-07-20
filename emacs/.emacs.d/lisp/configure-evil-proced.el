;; -*- lexical-binding: t; -*-

(progn ;; proced
  (require 'evil)
  (require 'proced)

  (defun evil-collection-proced-setup ()
    "Set up Evil bindings for Proced."
    (evil-set-initial-state 'proced-mode 'normal)

    (evil-define-key 'normal proced-mode-map
      (kbd "RET") #'proced-refine
      "m" #'proced-mark
      "*" #'proced-mark-all
      "M" #'proced-mark-all
      "U" #'proced-unmark-all
      "~" #'proced-toggle-marks
      "c" #'proced-mark-children
      "p" #'proced-mark-parents
      "zt" #'proced-toggle-tree
      "u" #'proced-undo
      "O" #'proced-omit-processes
      "x" #'proced-send-signal
      "s" #'proced-filter-interactive
      "S" #'proced-format-interactive
      "oo" #'proced-sort-start
      "oO" #'proced-sort-interactive
      "oc" #'proced-sort-pcpu
      "om" #'proced-sort-pmem
      "op" #'proced-sort-pid
      "ot" #'proced-sort-time
      "ou" #'proced-sort-user
      "r" #'proced-renice
      "gr" #'revert-buffer
      "q" #'quit-window))

  (evil-collection-proced-setup))

(provide 'configure-evil-proced)
