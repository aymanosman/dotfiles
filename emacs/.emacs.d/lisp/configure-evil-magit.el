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

  (evil-define-operator evil-collection-magit-yank-whole-line
    (beg end type register yank-handler)
    "Yank whole line."
    :motion evil-line-or-visual-line
    (interactive "<R><x>")
    (evil-yank beg end type register yank-handler))

  (defun evil-collection-magit-set-initial-states ()
    "Set the initial state for relevant Magit modes."
    (dolist (mode evil-collection-magit-emacs-to-evil-collection-magit-state-modes)
      (evil-set-initial-state mode 'normal))
    (dolist (mode '(magit-blob-mode magit-gitflow-mode))
      (evil-set-initial-state mode 'normal))
    (evil-set-initial-state 'git-commit-mode evil-default-state)
    (evil-set-initial-state 'magit-submodule-list-mode 'normal))

  (defun evil-collection-magit-remove-visual-activate-hook ()
    "Keep `set-mark-command' from entering Visual state in Magit buffers."
    (when (derived-mode-p 'magit-mode)
      (remove-hook 'activate-mark-hook #'evil-visual-activate-hook t)))

  (add-hook 'evil-local-mode-hook
            #'evil-collection-magit-remove-visual-activate-hook)

  (defvar evil-collection-magit-in-visual-pre-command nil)

  (defun evil-collection-magit--around-visual-pre-command (function &rest args)
    "Call FUNCTION with ARGS while preparing a Magit visual command."
    (let ((evil-collection-magit-in-visual-pre-command t))
      (apply function args)))

  (defun evil-collection-magit--filter-args-visual-expand-region (args)
    "Exclude the final newline from linewise Magit visual selections."
    (cons (or (car args)
              (and evil-collection-magit-in-visual-pre-command
                   (eq (evil-visual-type) 'line)
                   (derived-mode-p 'magit-mode)))
          (cdr args)))

  (unless (advice-member-p #'evil-collection-magit--around-visual-pre-command
                           'evil-visual-pre-command)
    (advice-add 'evil-visual-pre-command
                :around #'evil-collection-magit--around-visual-pre-command))
  (unless (advice-member-p #'evil-collection-magit--filter-args-visual-expand-region
                           'evil-visual-expand-region)
    (advice-add 'evil-visual-expand-region
                :filter-args #'evil-collection-magit--filter-args-visual-expand-region))

  ;; Keep a linewise visual selection active while moving between sections.
  (dolist (command '(magit-section-forward-sibling
                     magit-section-forward
                     magit-section-backward-sibling
                     magit-section-backward
                     magit-section-up))
    (evil-set-command-property command :keep-visual t))

  (defun evil-collection-magit-stage-untracked-file-with-intent ()
    "Stage the untracked file at point with intent to add."
    (interactive)
    (when (and (derived-mode-p 'magit-mode)
               (magit-apply--get-selection)
               (eq (magit-diff-type) 'untracked))
      (magit-stage-untracked t)))

  (defun evil-collection-magit-adjust-section-bindings ()
    "Set bindings in Magit section text-property maps."
    ;; Evil's auxiliary maps do not apply to these maps.
    (define-key magit-file-section-map "I"
                #'evil-collection-magit-stage-untracked-file-with-intent)
    (dolist (map (list magit-file-section-map magit-hunk-section-map))
      (define-key map (kbd "C-j") nil)
      (define-key map (kbd "RET") #'magit-diff-visit-file)
      (define-key map (kbd "S-<return>") #'magit-diff-visit-worktree-file)))

  (defvar evil-collection-magit-popup-keys-changed nil)

  (defvar evil-collection-magit-popup-changes
    '((magit-branch "x" "X" magit-branch-reset)
      (magit-branch "k" "x" magit-branch-delete)
      (magit-dispatch "o" "'" magit-submodule)
      (magit-dispatch "O" "\"" magit-subtree)
      (magit-dispatch "V" "_" magit-revert)
      (magit-dispatch "X" "O" magit-reset)
      (magit-dispatch "v" "-" magit-reverse)
      (magit-dispatch "k" "x" magit-discard)
      (magit-remote "k" "x" magit-remote-remove)
      (magit-revert "V" "_" magit-revert-and-commit)
      (magit-revert "V" "_" magit-sequencer-continue)
      (magit-tag "k" "x" magit-tag-delete))
    "Changes to Magit transient keys.")

  (defun evil-collection-magit-change-popup-key (popup from to &rest _args)
    "Change a suffix in POPUP from FROM to TO."
    (transient-suffix-put popup from :key to))

  (defun evil-collection-magit-adjust-popups ()
    "Adjust transient keys to match the Evil Magit bindings."
    (unless evil-collection-magit-popup-keys-changed
      (dolist (change evil-collection-magit-popup-changes)
        (apply #'evil-collection-magit-change-popup-key change))
      (setq evil-collection-magit-popup-keys-changed t)))

  (define-minor-mode evil-collection-magit-toggle-text-minor-mode
    "Support returning from `text-mode' to the previous Magit mode."
    :keymap (make-sparse-keymap))

  (defvar evil-collection-magit-last-mode nil
    "Last Magit mode before entering `text-mode'.")

  (defun evil-collection-magit-toggle-text-mode ()
    "Switch between a Magit mode and editable `text-mode'."
    (interactive)
    (cond
     ((derived-mode-p 'magit-mode 'git-rebase-mode)
      (setq evil-collection-magit-last-mode major-mode)
      (text-mode)
      (read-only-mode -1)
      (evil-collection-magit-toggle-text-minor-mode 1)
      (evil-normalize-keymaps))
     ((and (eq major-mode 'text-mode)
           (functionp evil-collection-magit-last-mode))
      (evil-collection-magit-toggle-text-minor-mode -1)
      (evil-normalize-keymaps)
      (funcall evil-collection-magit-last-mode)
      (magit-refresh)
      (evil-change-state 'normal))
     (t
      (user-error "Not in a Magit buffer or Magit text-mode buffer"))))

  (defun evil-collection-magit-setup ()
    "Set up Evil bindings for Magit."
    (evil-collection-magit-set-initial-states)

    (dolist (map '(magit-mode-map
                   magit-cherry-mode-map
                   magit-blob-mode-map
                   magit-diff-mode-map
                   magit-log-mode-map
                   magit-log-read-revs-map
                   magit-log-select-mode-map
                   magit-process-mode-map
                   magit-reflog-mode-map
                   magit-refs-mode-map
                   magit-status-mode-map))
      (when (boundp map)
        (evil-make-overriding-map (symbol-value map) 'all)))
    (evil-make-overriding-map magit-blame-read-only-mode-map 'normal)

    (evil-define-key '(normal visual) magit-mode-map
      "g" nil
      (kbd "C-j") #'magit-section-forward
      (kbd "M-j") #'magit-section-forward-sibling
      "gj" #'magit-section-forward-sibling
      "]" #'magit-section-forward-sibling
      (kbd "C-k") #'magit-section-backward
      (kbd "M-k") #'magit-section-backward-sibling
      "gk" #'magit-section-backward-sibling
      "[" #'magit-section-backward-sibling
      "gr" #'magit-refresh
      "gR" #'magit-refresh-all
      "x" #'magit-delete-thing
      "X" #'magit-file-untrack
      "-" #'magit-revert-no-commit
      "_" #'magit-revert
      "p" #'magit-push
      "o" #'magit-reset-quickly
      "O" #'magit-reset
      "|" #'magit-git-command
      "'" #'magit-submodule
      "\"" #'magit-subtree
      "=" #'magit-diff-less-context
      "j" #'evil-next-line
      "k" #'evil-previous-line
      "gg" #'evil-goto-first-line
      "G" #'evil-goto-line
      (kbd "C-d") #'evil-scroll-down
      (kbd "C-f") #'evil-scroll-page-down
      (kbd "C-b") #'evil-scroll-page-up
      ":" #'evil-ex
      "q" #'magit-mode-bury-buffer
      (kbd "S-SPC") #'magit-diff-show-or-scroll-up
      (kbd "S-DEL") #'magit-diff-show-or-scroll-down
      "v" #'evil-visual-line
      "V" #'evil-visual-line
      (kbd "C-w") evil-window-map
      "y" nil
      "yy" #'evil-collection-magit-yank-whole-line
      "yr" #'magit-show-refs
      "ys" #'magit-copy-section-value
      "yb" #'magit-copy-buffer-revision
      "$" #'evil-end-of-line
      "`" #'magit-process-buffer
      "0" #'evil-beginning-of-line
      "~" #'magit-diff-default-context)

    (evil-define-key 'normal magit-mode-map
      (kbd evil-toggle-key) #'evil-emacs-state
      (kbd "C-t") #'evil-collection-magit-toggle-text-mode
      "\\" #'evil-collection-magit-toggle-text-mode)

    (evil-define-key 'visual magit-mode-map
      "y" #'magit-copy-section-value)

    (if (eq evil-search-module 'evil-search)
        (evil-define-key '(normal visual) magit-mode-map
          "/" #'evil-ex-search-forward
          "n" #'evil-ex-search-next
          "N" #'evil-ex-search-previous)
      (evil-define-key '(normal visual) magit-mode-map
        "/" #'evil-search-forward
        "n" #'evil-search-next
        "N" #'evil-search-previous))

    (when evil-want-C-u-scroll
      (evil-define-key '(normal visual) magit-mode-map
        (kbd "C-u") #'evil-scroll-up))

    (evil-define-key '(normal visual) magit-log-mode-map
      "=" #'magit-log-toggle-commit-limit)

    (evil-define-key '(normal visual) magit-status-mode-map
      "gz" #'magit-jump-to-stashes
      "gt" #'magit-jump-to-tracked
      "gn" #'magit-jump-to-untracked
      "gu" #'magit-jump-to-unstaged
      "gs" #'magit-jump-to-staged
      "gfu" #'magit-jump-to-unpulled-from-upstream
      "gfp" #'magit-jump-to-unpulled-from-pushremote
      "gpu" #'magit-jump-to-unpushed-to-upstream
      "gpp" #'magit-jump-to-unpushed-to-pushremote
      "gh" #'magit-section-up)

    (evil-define-key '(normal visual) magit-diff-mode-map
      "gd" #'magit-jump-to-diffstat-or-diff)
    (evil-define-key 'visual magit-diff-mode-map
      "y" #'magit-copy-section-value)

    (evil-define-key '(normal visual) magit-blob-mode-map
      "gj" #'magit-blob-next
      "gk" #'magit-blob-previous)

    (evil-define-key '(normal visual) git-commit-mode-map
      (kbd "M-k") #'git-commit-prev-message
      "gk" #'git-commit-prev-message
      (kbd "M-j") #'git-commit-next-message
      "gj" #'git-commit-next-message)

    (evil-define-key 'normal magit-blame-read-only-mode-map
      "j" #'evil-next-line
      (kbd "C-j") #'magit-blame-next-chunk
      "gj" #'magit-blame-next-chunk
      "gJ" #'magit-blame-next-chunk-same-commit
      "k" #'evil-previous-line
      (kbd "C-k") #'magit-blame-previous-chunk
      "gk" #'magit-blame-previous-chunk
      "gK" #'magit-blame-previous-chunk-same-commit
      "q" #'magit-blame-quit)

    (if (eq evil-search-module 'evil-search)
        (evil-define-key '(normal visual) magit-blame-read-only-mode-map
          "n" #'evil-ex-search-next
          "N" #'evil-ex-search-previous)
      (evil-define-key '(normal visual) magit-blame-read-only-mode-map
        "n" #'evil-search-next
        "N" #'evil-search-previous))

    (evil-define-key 'normal magit-blame-mode-map
      "q" #'magit-blame-quit)

    (evil-define-key 'normal magit-submodule-list-mode-map
      (kbd "RET") #'magit-repolist-status
      "gr" #'magit-list-submodules)

    (evil-define-key 'normal evil-collection-magit-toggle-text-minor-mode-map
      (kbd "C-t") #'evil-collection-magit-toggle-text-mode
      "\\" #'evil-collection-magit-toggle-text-mode)

    (dolist (hook '(magit-mode-hook
                    magit-blame-mode-hook
                    magit-blob-mode-hook
                    magit-submodule-list-mode-hook))
      (add-hook hook #'evil-normalize-keymaps))

    (evil-collection-magit-adjust-section-bindings)
    (evil-collection-magit-adjust-popups))

  (evil-collection-magit-setup))

(progn ;; git-rebase
  (require 'git-rebase)

  (defvar evil-collection-magit-rebase-commands-w-descriptions
    '(("p" git-rebase-pick "pick = use commit")
      ("r" git-rebase-reword "reword = use commit, but edit the commit message")
      ("e" git-rebase-edit "edit = use commit, but stop for amending")
      ("s" git-rebase-squash "squash = use commit, but meld into previous commit")
      ("f" git-rebase-fixup "fixup = like squash, but discard this commit's log message")
      ("x" git-rebase-exec "exec = run command using shell")
      ("d" git-rebase-kill-line "drop = remove commit")
      ("u" git-rebase-undo "undo last change")
      ("ZZ" with-editor-finish "tell Git to make it happen")
      ("ZQ" with-editor-cancel "tell Git that you changed your mind")
      ("k" evil-previous-line "move point to previous line")
      ("j" evil-next-line "move point to next line")
      ("M-k" git-rebase-move-line-up "move the commit at point up")
      ("M-j" git-rebase-move-line-down "move the commit at point down")
      (nil git-rebase-show-commit "show the commit at point in another buffer")))

  (defun evil-collection-magit-add-rebase-messages ()
    "Replace the rebase instructions with the active Evil bindings."
    (goto-char (point-min))
    (let ((inhibit-read-only t)
          (state-regexp "<normal-state> ")
          (aux-map (evil-get-auxiliary-keymap git-rebase-mode-map 'normal)))
      (save-excursion
        (save-match-data
          (when (and (boundp 'git-rebase-show-instructions)
                     git-rebase-show-instructions
                     (re-search-forward
                      (concat "^" (regexp-quote comment-start) "\\s-+p, pick") nil t))
            (goto-char (line-beginning-position))
            (flush-lines (concat "^" (regexp-quote comment-start) ".+ = "))
            (dolist (command evil-collection-magit-rebase-commands-w-descriptions)
              (insert
               (format "%s %-8s %s\n"
                       comment-start
                       (if (and (car command)
                                (eq (nth 1 command)
                                    (lookup-key aux-map (kbd (car command)))))
                           (car command)
                         (replace-regexp-in-string
                          state-regexp ""
                          (substitute-command-keys
                           (format "\\[%s]" (nth 1 command)))))
                       (nth 2 command)))))))))

  (evil-set-initial-state 'git-rebase-mode 'normal)
  (evil-make-overriding-map git-rebase-mode-map 'normal)

  (dolist (command evil-collection-magit-rebase-commands-w-descriptions)
    (when (car command)
      (evil-define-key 'normal git-rebase-mode-map
        (kbd (car command)) (nth 1 command))))

  (evil-define-key 'normal git-rebase-mode-map
    (kbd "C-t") #'evil-collection-magit-toggle-text-mode
    "\\" #'evil-collection-magit-toggle-text-mode)

  (remove-hook 'git-rebase-mode-hook #'git-rebase-mode-show-keybindings)
  (add-hook 'git-rebase-mode-hook #'evil-collection-magit-add-rebase-messages t)
  (add-hook 'git-rebase-mode-hook #'evil-normalize-keymaps))

(provide 'configure-evil-magit)
