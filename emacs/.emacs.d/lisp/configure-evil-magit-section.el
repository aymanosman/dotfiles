;; -*- lexical-binding: t; -*-

(progn ;; magit-section
  (require 'evil)
  (require 'magit-section)

  (defun evil-collection-magit-section-setup ()
    "Set up Evil bindings for Magit Section."
    (evil-define-key 'normal magit-section-mode-map
      (kbd "<tab>") #'magit-section-toggle
      (kbd "TAB") #'magit-section-toggle
      (kbd "<backtab>") #'magit-section-cycle-global
      (kbd "<S-tab>") #'magit-section-cycle-global
      [C-tab] #'magit-section-cycle
      [M-tab] #'magit-section-cycle
      "gh" #'magit-section-up
      (kbd "C-k") #'magit-section-backward
      (kbd "C-j") #'magit-section-forward
      "gk" #'magit-section-backward-sibling
      "gj" #'magit-section-forward-sibling
      "[" #'magit-section-backward-sibling
      "]" #'magit-section-forward-sibling
      "1" #'magit-section-show-level-1
      "2" #'magit-section-show-level-2
      "3" #'magit-section-show-level-3
      "4" #'magit-section-show-level-4
      (kbd "M-1") #'magit-section-show-level-1-all
      (kbd "M-2") #'magit-section-show-level-2-all
      (kbd "M-3") #'magit-section-show-level-3-all
      (kbd "M-4") #'magit-section-show-level-4-all))

  (evil-collection-magit-section-setup))

(provide 'configure-evil-magit-section)
