;; -*- lexical-binding: t; -*-

(progn ;; replace
  (require 'evil)
  (require 'replace)

  (defun evil-collection-replace-setup ()
    "Set up Evil bindings for Occur."
    (evil-set-initial-state 'occur-mode 'normal)

    (evil-define-key 'normal occur-mode-map
      (kbd "C-x C-q") #'occur-edit-mode
      "i" #'occur-edit-mode
      (kbd "RET") #'occur-mode-goto-occurrence
      (kbd "S-<return>") #'occur-mode-goto-occurrence-other-window
      (kbd "M-<return>") #'occur-mode-display-occurrence
      "go" #'occur-mode-goto-occurrence-other-window
      "gj" #'next-error-no-select
      "gk" #'previous-error-no-select
      (kbd "C-j") #'next-error-no-select
      (kbd "C-k") #'previous-error-no-select
      "r" #'occur-rename-buffer
      "q" #'quit-window)

    (evil-define-key 'normal occur-edit-mode-map
      (kbd "C-x C-q") #'occur-cease-edit
      (kbd "C-c C-c") #'occur-cease-edit
      (kbd "<escape>") #'occur-cease-edit
      "ZZ" #'occur-cease-edit
      "ZQ" #'occur-cease-edit))

  (evil-collection-replace-setup))

(provide 'configure-evil-replace)
