;; -*- lexical-binding: t; -*-

(progn ;; corfu
  (require 'evil)
  (require 'corfu)

  (defvar evil-collection-corfu-supported-states '(insert replace emacs nil)
    "Evil states in which Corfu can continue completion.")

  (defun evil-collection-corfu-quit-and-escape ()
    "Quit Corfu and return to Normal state."
    (interactive)
    (call-interactively #'corfu-quit)
    (evil-normal-state))

  (defun evil-collection-corfu-setup ()
    "Set up Evil bindings for Corfu."
    (evil-define-key 'insert corfu-map
      (kbd "C-n") #'corfu-next
      (kbd "C-p") #'corfu-previous
      (kbd "C-j") #'corfu-next
      (kbd "C-k") #'corfu-previous
      (kbd "M-j") #'corfu-next
      (kbd "M-k") #'corfu-previous
      (kbd "<down>") #'corfu-next
      (kbd "<up>") #'corfu-previous
      (kbd "<escape>") #'evil-collection-corfu-quit-and-escape)

    (advice-add 'corfu--setup :after
                (lambda (&rest _) (evil-normalize-keymaps)))
    (advice-add 'corfu--teardown :after
                (lambda (&rest _) (evil-normalize-keymaps)))
    (advice-add 'corfu--continue-p :before-while
                (lambda (&rest _)
                  (memq evil-state evil-collection-corfu-supported-states)))

    (mapc #'evil-declare-ignore-repeat
          '(corfu-next corfu-previous corfu-first corfu-last)))

  (evil-collection-corfu-setup))

(provide 'configure-evil-corfu)
