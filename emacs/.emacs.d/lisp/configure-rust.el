(progn ;; rustic

  (install 'rust-mode)

  (setq rust-format-on-save t)

  (setq rust-mode-treesitter-derive t)

  (install 'rustic)
  (setq ristic-lsp-client 'eglot)

  (add-hook 'rust-mode-hook 'eglot-ensure)

  (add-to-list 'eglot-server-programs
               '((rust-ts-mode rest-mode) .
                 ("rust-analyzer" :initializationOptions (:check (:command "clippy"))))))
