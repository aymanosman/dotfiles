;; -*- lexical-binding: t; -*-

(progn ;; magit
  (require 'evil)
  (require 'magit)

  (defvar evil-collection-magit-emacs-to-evil-collection-magit-state-modes
    '(magit-mode
      magit-cherry-mode
      magit-diff-mode
      magit-log-mode
      magit-log-select-mode
      magit-process-mode
      magit-reflog-mode
      magit-refs-mode
      magit-revision-mode
      magit-stash-mode
      magit-stashes-mode
      magit-status-mode)
    "Magit modes that should start in Normal state.")

  (defun evil-collection-magit-set-initial-states ()
    "Set the initial state for relevant Magit modes."
    (dolist (mode evil-collection-magit-emacs-to-evil-collection-magit-state-modes)
      (evil-set-initial-state mode 'normal)))

  (defun evil-collection-magit-adjust-section-bindings ()
    "Set bindings in Magit section text-property maps."
    ;; Evil's auxiliary maps do not apply to these maps.
    (dolist (map (list magit-file-section-map magit-hunk-section-map))
      (define-key map (kbd "RET") #'magit-diff-visit-file)
      (define-key map (kbd "S-<return>") #'magit-diff-visit-worktree-file)))

  (defun evil-collection-magit-setup ()
    "Set up Evil bindings for Magit."
    (evil-collection-magit-set-initial-states)

    (dolist (map '(magit-mode-map
                   magit-diff-mode-map
                   magit-log-mode-map
                   magit-log-select-mode-map
                   magit-process-mode-map
                   magit-reflog-mode-map
                   magit-refs-mode-map
                   magit-status-mode-map))
      (when (boundp map)
        (evil-make-overriding-map (symbol-value map) 'normal)))

    (evil-define-key 'normal magit-mode-map
      "j" #'evil-next-line
      "k" #'evil-previous-line
      "gg" #'evil-goto-first-line
      "G" #'evil-goto-line
      "/" #'evil-search-forward
      "n" #'evil-search-next
      "N" #'evil-search-previous
      (kbd "C-j") #'magit-section-forward
      (kbd "C-k") #'magit-section-backward
      "gj" #'magit-section-forward-sibling
      "gk" #'magit-section-backward-sibling
      "gh" #'magit-section-up
      "gr" #'magit-refresh
      "gR" #'magit-refresh-all
      "q" #'magit-mode-bury-buffer)

    (add-hook 'magit-mode-hook #'evil-normalize-keymaps)
    (evil-collection-magit-adjust-section-bindings))

  (evil-collection-magit-setup))

(progn ;; git-rebase
  (require 'git-rebase)

  (evil-set-initial-state 'git-rebase-mode 'normal)
  (evil-make-overriding-map git-rebase-mode-map 'normal)
  (evil-define-key 'normal git-rebase-mode-map
    "j" #'evil-next-line
    "k" #'evil-previous-line
    (kbd "M-j") #'git-rebase-move-line-down
    (kbd "M-k") #'git-rebase-move-line-up)
  (add-hook 'git-rebase-mode-hook #'evil-normalize-keymaps))

(provide 'configure-evil-magit)
