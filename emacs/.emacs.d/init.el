;; -*- lexical-binding: t; -*-

(setq inhibit-startup-message t
      ns-command-modifier 'meta
      mac-option-modifier 'meta
      create-lockfiles nil
      make-backup-files nil
      vc-follow-symlinks t
      ring-bell-function #'ignore
      scroll-step 1
      scroll-conservatively 101
      sh-basic-offset 2
      sentence-end-double-space nil
      dired-listing-switches "-alh"
      global-auto-revert-non-file-buffers t
      switch-to-buffer-obey-display-actions t
      read-extended-command-predicate #'command-completion-default-include-p
      use-dialog-box nil)

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(setq-default indent-tabs-mode nil)
(setq tab-always-indent 'complete)

(load-theme 'modus-vivendi t)

(set-face-attribute 'default nil :family "Iosevka" :height 160)
(set-face-attribute 'variable-pitch nil :family "Iosevka Aile")

(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-auto-revert-mode 1)
(savehist-mode 1)
(save-place-mode 1)
(global-hl-line-mode 1)

(put 'narrow-to-region 'disabled nil)

(global-set-key (kbd "C-=") #'text-scale-increase)
(global-set-key (kbd "C--") #'text-scale-decrease)
(global-set-key [remap dabbrev-expand] 'hippie-expand)

(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)

(progn ;; server
  (require 'server)
  (unless (server-running-p)
    (server-start)))

;;; packages

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/")
             t)

(package-initialize)

(defun install (pkg)
  (unless (package-installed-p pkg)
    (package-install pkg))
  (require pkg))

(defun install-vc (url &optional pkg)
  (unless (package-installed-p pkg)
    (package-vc-install url nil nil pkg))
  (require pkg))

(progn ;; evil
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-undo-system 'undo-redo)

  (install 'evil)

  (setq evil-normal-state-cursor '(box "light blue")
        evil-insert-state-cursor '(bar "medium sea green")
        evil-visual-state-cursor '(hollow "orange")
        evil-emacs-state-cursor '(box "orange"))
  (setq evil-symbol-word-search t)

  (evil-mode 1)

  (define-key global-map (kbd "<escape>") 'keyboard-escape-quit))

(progn ;; evil-collection
  (install 'evil-collection)
  (setq evil-collection-want-unimpaired-p nil)
  (evil-collection-init '(calendar magit magit-section debug edebug corfu replace proced)))

(progn ;; which-key
  (install 'which-key)
  (which-key-mode))

(progn ;; vertico
  (install 'vertico)
  (vertico-mode))

(progn ;; emacs
  (define-key minibuffer-local-completion-map " " 'self-insert-command)
  (define-key minibuffer-local-completion-map "?" 'self-insert-command))

(progn ;; orderless
  (install 'orderless)
  (setq completion-styles '(orderless flex basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))))

(progn ;; marginalia
  (install 'marginalia)
  (marginalia-mode))

(progn ;; corfu
  (install 'corfu)
  (setq corfu-auto t)
  (global-corfu-mode))

(progn ;; consult
  (setq consult-project-root-function
        (lambda ()
          (when-let (project (project-current))
            (car (project-roots project)))))

  (keymap-global-set "C-x b" 'consult-buffer)
  (keymap-global-set "M-y" 'consult-yank-pop))

(progn ;; embark
  (install 'embark)

  (keymap-global-set "C-." #'embark-act)
  (keymap-global-set "C-;" #'embark-dwim)

  (evil-define-key 'normal global-map
    (kbd "C-.") #'embark-act))

(progn ;; embark-consult
  (install 'embark-consult)

  (add-hook 'embark-collect-mode-hook #'consult-preview-at-point-mode))

(progn ;; smartparens
  (install 'smartparens)
  (require 'smartparens-config)

  (cl-dolist (mode-hook '(emacs-lisp-mode-hook
                          lisp-mode-hook
                          lisp-interaction-mode-hook))
    (add-hook mode-hook #'smartparens-strict-mode)))

(progn ;; evil - smartparens
  (define-key evil-normal-state-map (kbd ">") #'sp-forward-slurp-sexp)
  (define-key evil-normal-state-map (kbd "<") #'sp-forward-barf-sexp)
  (define-key evil-insert-state-map (kbd "M->") #'sp-forward-slurp-sexp))

(progn ;; evil - unimpaired
  (defun evil-impaired-insert-space-above (count)
    (interactive "p")
    (save-excursion
      (dotimes (_ count)
        (evil-insert-newline-above))))

  (defun evil-impaired-insert-space-below (count)
    (interactive "p")
    (save-excursion
      (dotimes (_ count)
        (evil-insert-newline-below))))

  (define-key evil-normal-state-map (kbd "SPC O") #'evil-impaired-insert-space-above)
  (define-key evil-normal-state-map (kbd "SPC o") #'evil-impaired-insert-space-below))

(progn ;; evil - insert mode
  (define-key evil-insert-state-map (kbd "C-e") #'move-end-of-line)
  (define-key evil-insert-state-map (kbd "C-a") #'move-beginning-of-line))

(progn ;; evil - misc
  (define-key evil-normal-state-map (kbd "K") #'describe-symbol)
  (define-key evil-normal-state-map (kbd "M-.") 'xref-find-definitions)

  (define-key evil-motion-state-map [down-mouse-1] nil)
  (define-key evil-motion-state-map [down-mouse-1] 'mouse-drag-region)

  (define-key global-map (kbd "M-s") #'save-buffer)
  (define-key global-map (kbd "M-v") #'cua-paste))

(progn ;; evil - error navigation
  (add-hook 'prog-mode-hook
            (lambda ()
              (define-key evil-normal-state-local-map (kbd "] e") #'next-error)
              (define-key evil-normal-state-local-map (kbd "[ e") #'previous-error))))

(progn ;; evil - window management
  (define-key evil-normal-state-map (kbd "SPC w j") #'evil-window-down)
  (define-key evil-normal-state-map (kbd "SPC w k") #'evil-window-up)
  (define-key evil-normal-state-map (kbd "SPC w l") #'evil-window-right)
  (define-key evil-normal-state-map (kbd "SPC w h") #'evil-window-left)
  (define-key evil-normal-state-map (kbd "SPC w s") #'evil-window-split)
  (define-key evil-normal-state-map (kbd "SPC w v") #'evil-window-vsplit)
  (define-key evil-normal-state-map (kbd "SPC w d") #'evil-window-delete)
  (define-key evil-normal-state-map (kbd "SPC w o") #'delete-other-windows))

(progn ;; evil - buffer management
  (require 'ibuf-ext)

  (defun kill-all-other-buffers ()
    (interactive)
    (mapc (lambda (x)
            (unless (or (eq ?\s (aref (buffer-name x) 0))
                        (eq ?\* (aref (buffer-name x) 0))
                        (string-equal (buffer-name (current-buffer)) (buffer-name x)))
              (ignore-errors (kill-buffer x))))
          (buffer-list)))

  (cl-flet ((put (key def)
              (define-key evil-normal-state-map (kbd key) def)))
    (put "SPC b b" #'consult-buffer)
    (put "SPC b i" #'ibuffer)
    (define-key global-map [remap list-buffers] 'ibuffer)
    (put "SPC b d" (defun kill-current-buffer ()
                     (interactive)
                     (kill-buffer (current-buffer))))
    (put "SPC b l" #'evil-buffer)
    (put "SPC b m" #'bookmark-set)
    (put "SPC b j" #'bookmark-jump)
    (put "SPC b s" (defun goto-scratch-buffer ()
                     (interactive)
                     (switch-to-buffer "*scratch*")))
    (put "SPC b O" #'kill-all-other-buffers))

  (define-key evil-normal-state-map (kbd "SPC j r") 'jump-to-register))

(progn ;; evil - file management
  (defun delete-current-file ()
    (interactive)
    (let ((buffer (current-buffer)))
      (delete-file (buffer-file-name buffer))
      (kill-buffer buffer)))

  (defun a/find-user-emacs-file (filename)
    (interactive (list (read-file-name "User Emacs File: " user-emacs-directory)))
    (find-file filename))

  (define-key evil-normal-state-map (kbd "SPC f s") #'save-buffer)
  (define-key evil-normal-state-map (kbd "SPC f f") #'find-file)
  (define-key evil-normal-state-map (kbd "SPC f r") #'rename-visited-file)
  (define-key evil-normal-state-map (kbd "SPC f d") #'delete-current-file)
  (define-key evil-normal-state-map (kbd "SPC f p") #'a/find-user-emacs-file))

(progn ;; magit
  (install 'magit)
  (install 'git-modes)

  (add-hook 'gitignore-mode-hook
            (lambda ()
              (setq require-final-newline t)))

  (defun set-fill-column-80 ()
    (setq-local fill-column 80))

  (add-hook 'text-mode-hook 'set-fill-column-80)

  (define-key evil-normal-state-map (kbd "SPC g g") #'magit)
  (define-key evil-normal-state-map (kbd "SPC g b") #'magit-branch-checkout)
  (define-key evil-normal-state-map (kbd "SPC g l") #'magit-log-current))

(progn ;; winner
  (install 'winner)
  (keymap-set global-map "M-[" 'winner-undo)
  (keymap-set global-map "M-]" 'winner-redo)
  (winner-mode))

(progn ;; rainbow-delimiters
  (install 'rainbow-delimiters)

  (cl-dolist (mode-hook '(emacs-lisp-mode-hook lisp-mode-hook))
    (add-hook mode-hook #'rainbow-delimiters-mode)))

(progn ;; calendar
  (setq calendar-week-start-day 1
        calendar-date-style 'iso))

(progn ;; default-text-scale
  (install 'default-text-scale)
  (default-text-scale-mode 1))

(progn ;; prog-mode
  (add-hook 'prog-mode-hook (lambda ()
                              (add-hook 'before-save-hook 'whitespace-cleanup 0 t)))
  (add-hook 'prog-mode-hook #'display-line-numbers-mode))

(progn ;; xref
  (setq xref-show-definitions-function #'xref-show-definitions-completing-read))

(progn ;; consult - SPC leader
  (defvar consult-space-map nil
    "Keymap for consult under SPC leader")

  (setf consult-space-map
        (let ((map (make-sparse-keymap)))
          (keymap-set map "i" #'consult-imenu)
          (keymap-set map "s" #'consult-line)
          (keymap-set map "p" #'consult-ripgrep)
          map))

  (keymap-set evil-normal-state-map "SPC s" consult-space-map))

(progn ;; evil - tabulated-list-mode
  (evil-define-key nil tabulated-list-mode-map
    "n" nil
    "p" nil)

  (evil-set-initial-state 'tabulated-list-mode 'normal)

  (evil-define-key 'normal tabulated-list-mode-map
    "S" 'tabulated-list-sort
    "{" 'tabulated-list-narrow-current-column
    "}" 'tabulated-list-widen-current-column
    "gl" 'tabulated-list-next-column
    "gh" 'tabulated-list-previous-column
    "q" 'quit-window))

(progn ;; completion-in-region
  (setq completion-in-region-function
        (lambda (&rest args)
          (apply (if vertico-mode
                     #'consult-completion-in-region
                   #'completion--in-region)
                 args)))

  (add-hook 'minibuffer-mode-hook 'vertico-mode)

  (defun corfu-enable-in-minibuffer ()
    "Enable Corfu in the minibuffer if `completion-at-point' is bound."
    (when (where-is-internal #'completion-at-point (list (current-local-map)))
      (setq-local corfu-echo-delay nil
                  corfu-popupinfo-delay nil)
      (corfu-mode 1)))

  (add-hook 'minibuffer-setup-hook #'corfu-enable-in-minibuffer))

(progn ;; project
  (require 'monorepo)

  (setq project-find-functions '(monorepo-try-find-project
                                 project-try-vc))

  (define-key evil-normal-state-map (kbd "SPC p f") #'project-find-file)
  (define-key evil-normal-state-map (kbd "SPC p p") #'project-switch-project)

  (defun switch-project-and-find-file ()
    (interactive)
    (let ((project-switch-commands 'project-find-file))
      (call-interactively 'project-switch-project)))

  (global-set-key [remap project-switch-project] #'switch-project-and-find-file))

(progn ;; treesit
  (setq treesit-font-lock-level 4))

(progn ;; org
  (setq org-image-actual-width nil
        org-src-preserve-indentation t
        org-read-date-popup-calendar t
        org-confirm-babel-evaluate nil
        org-export-babel-evaluate nil)

  (org-clock-persistence-insinuate)
  (setq org-clock-persist 'history)

  (add-hook 'org-mode-hook (defun configure-org-mode ()
                             (org-indent-mode 1)))

  (keymap-global-set "C-c a" 'org-agenda)
  (keymap-global-set "C-c l" 'org-store-link)
  (keymap-global-set "C-c c" 'org-capture))

(progn ;; eww
  (setq shr-use-fonts nil)
  (setq shr-width 80))

(progn ;; avy
  (install 'avy)

  (define-key evil-normal-state-map (kbd "SPC j w") #'avy-goto-word-1))

(progn ;; eldoc
  (setq eldoc-echo-area-use-multiline-p nil))

(progn ;; eldoc-box
  (install 'eldoc-box)
  (eldoc-box-hover-at-point-mode))

(progn ;; tempel
  (install 'tempel)

  (setq tempel-trigger-prefix "<")

  (defun tempel-setup-capf ()
    (setq-local completion-at-point-functions (cons #'tempel-complete completion-at-point-functions)))

  (add-hook 'conf-mode-hook 'tempel-setup-capf)
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf))

(progn ;; eglot
  (require 'eglot)
  (setq eglot-report-progress nil))

(progn ;; image-mode
  (setq image-auto-resize 'fit-window))

(progn ;; ediff
  (setq ediff-window-setup-function #'ediff-setup-windows-plain))

(progn ;; re-builder
  (setq reb-re-syntax 'string))

(progn ;; tramp
  (require 'tramp)
  (setq shell-file-name "/bin/sh")
  (setq-default explicit-shell-file-name "/bin/bash"))

(progn ;; vterm
  (install 'vterm)

  (setq vterm-shell explicit-shell-file-name)

  (define-key vterm-mode-map (kbd "M-v") 'vterm-yank)

  (evil-define-key 'normal vterm-mode-map
    "p" 'vterm-yank))

(progn ;; cape
  (install 'cape))

(progn ;; flymake
  (define-key flymake-mode-map (kbd "M-n") 'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-p") 'flymake-goto-prev-error))

(progn ;; evil flymake
  (dolist (map '(flymake-mode-map
                 flymake-diagnostics-buffer-mode-map
                 flymake-project-diagnostics-mode-map))
    (evil-define-key 'normal map
      "q" 'quit-window

      (kbd "C-j") 'flymake-goto-next-error
      (kbd "C-k") 'flymake-goto-prev-error
      (kbd "RET") 'flymake-goto-diagnostic
      (kbd "TAB") 'flymake-show-diagnostic)))

(progn ;; dumb-jump
  (install 'dumb-jump)
  (add-hook 'xref-backend-functions 'dumb-jump-xref-activate))

(progn ;; transpose-frame
  (install 'transpose-frame))

(progn ;; eros
  (install 'eros)
  (eros-mode 1))

(progn ;; evil dired

  (evil-define-key 'normal dired-mode-map
    "q" 'quit-window

    "^" 'dired-up-directory
    "+" 'dired-create-directory
    "d" 'dired-flag-file-deletion
    "x" 'dired-do-flagged-delete

    "g" 'revert-buffer

    "u" 'dired-unmark

    (kbd "RET") 'dired-find-file
    (kbd "TAB") 'dired-find-file-other-window))

(progn ;; dired-subtree
  (install 'dired-subtree))

(progn ;; evil dired-subtree

  (evil-define-key 'normal dired-mode-map
    (kbd "TAB") 'dired-subtree-toggle
    (kbd "S-TAB") 'dired-subtree-remove))

(progn ;; org-modern
  (install 'org-modern)

  (set-face-attribute 'org-modern-symbol nil :family "Iosevka")

  (dolist (face '(window-divider
                  window-divider-first-pixel
                  window-divider-last-pixel))
    (face-spec-reset-face face)
    (set-face-foreground face (face-attribute 'default :background)))
  (set-face-background 'fringe (face-attribute 'default :background))

  (setq org-auto-align-tags nil
        org-tags-column -67
        org-catch-invisible-edits 'show-and-error
        org-special-ctrl-a/e t
        org-insert-heading-respect-content t

        org-hide-emphasis-markers t
        org-pretty-entities t
        org-ellipsis "…"

        org-agenda-tags-column 'auto
        org-agenda-block-separator ?─
        org-agenda-time-grid
        '((daily today require-timed)
          (800 1000 1200 1400 1600 1800 2000)
          " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
        org-agenda-current-time-string
        "◀── now ─────────────────────────────────────────────────")

  (global-org-modern-mode 1))
