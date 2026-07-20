;; -*- lexical-binding: t; -*-

(progn ;; debug
  (require 'evil)
  (require 'debug)

  (defun evil-collection-debug-setup ()
    "Set up Evil bindings for the debugger."
    (evil-set-initial-state 'debugger-mode 'normal)

    (evil-define-key 'normal debugger-mode-map
      (kbd "TAB") #'forward-button
      (kbd "S-TAB") #'backward-button
      (kbd "RET") (if (fboundp 'debug-help-follow)
                      #'debug-help-follow
                    #'backtrace-help-follow-symbol)
      "c" #'debugger-continue
      "d" #'debugger-step-through
      "x" #'debugger-eval-expression
      "J" #'debugger-jump
      "gb" #'debugger-frame
      "r" #'debugger-return-value
      "q" #'top-level))

  (evil-collection-debug-setup))

(provide 'configure-evil-debug)
