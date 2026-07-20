;; -*- lexical-binding: t; -*-

(progn ;; edebug
  (require 'evil)
  (require 'edebug)

  (defun evil-collection-edebug-setup ()
    "Set up Evil bindings for Edebug."
    (evil-set-initial-state 'edebug-mode 'normal)
    (add-hook 'edebug-mode-hook #'evil-normalize-keymaps)

    (evil-define-key 'normal edebug-mode-map
      "s" #'edebug-step-mode
      "n" #'edebug-next-mode
      "go" #'edebug-go-mode
      "c" #'edebug-continue-mode
      "f" #'edebug-forward-sexp
      "i" #'edebug-step-in
      "o" #'edebug-step-out
      "b" #'edebug-set-breakpoint
      "u" #'edebug-unset-breakpoint
      "e" #'edebug-eval-expression
      "d" (if (fboundp 'edebug-pop-to-backtrace)
              #'edebug-pop-to-backtrace
            'edebug-backtrace)
      "q" #'top-level))

  (evil-collection-edebug-setup))

(provide 'configure-evil-edebug)
