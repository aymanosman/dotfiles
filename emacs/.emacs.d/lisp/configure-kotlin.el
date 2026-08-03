;; -*- lexical-binding: t; -*-

(progn ;; kotlin-ts-mode
  (require 'treesit)

  (add-to-list 'treesit-language-source-alist
               '(kotlin "https://github.com/fwcd/tree-sitter-kotlin"))

  (install 'kotlin-ts-mode)

  (add-to-list 'auto-mode-alist '("\\.kts?\\'" . kotlin-ts-mode)))

(progn ;; eglot
  (require 'eglot)

  (add-to-list 'eglot-server-programs
               '((kotlin-ts-mode kotlin-mode) . ("kotlin-lsp" "--stdio")))

  (add-hook 'kotlin-ts-mode-hook #'eglot-ensure))

(provide 'configure-kotlin)
