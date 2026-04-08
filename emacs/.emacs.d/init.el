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
