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

(setq-default indent-tabs-mode nil)
(setq tab-always-indent 'complete)

(load-theme 'modus-vivendi t)

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
