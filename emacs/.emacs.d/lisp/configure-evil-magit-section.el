;; -*- lexical-binding: t; -*-

(progn ;; magit-section
  (require 'evil)
  (require 'magit-section)

  (defun evil-collection-magit-section-setup ()
    "Set up Evil bindings for Magit Section."
    (evil-define-key 'normal magit-section-mode-map
      (kbd "TAB") #'magit-section-toggle
      (kbd "<backtab>") #'magit-section-cycle-global
      "gh" #'magit-section-up
      (kbd "C-k") #'magit-section-backward
      (kbd "C-j") #'magit-section-forward
      "gk" #'magit-section-backward-sibling
      "gj" #'magit-section-forward-sibling
      "1" #'magit-section-show-level-1
      "2" #'magit-section-show-level-2
      "3" #'magit-section-show-level-3
      "4" #'magit-section-show-level-4))

  (evil-collection-magit-section-setup))

(provide 'configure-evil-magit-section)
