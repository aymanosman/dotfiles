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
