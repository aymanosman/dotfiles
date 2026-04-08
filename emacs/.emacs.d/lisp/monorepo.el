;; -*- lexical-binding: t; -*-

(defvar monorepo-root-markers '(("package.json"
                                 (ignores . ("node_modules")))
                                ("Cargo.toml"
                                 (ignores . (".cargo/")))
                                ("mix.exs"
                                 (ignores . ("_build/" "deps/")))
                                "*.asd"))

(defun monorepo-try-find-project (dir)
  (let* ((found (monorepo--find-project dir)))
    (when found
      (let* ((root (car found))
             (properties (cadr found))
             (vc-backend (ignore-errors
                           (vc-responsible-backend root))))
        (if vc-backend
            (list 'vc vc-backend root)
          `(monorepo ,root ,properties))))))

(defun monorepo--find-project (dir)
  (seq-some (lambda (root-marker)
              (cl-destructuring-bind (root-marker properties)
                  (monorepo--normalize-root-marker root-marker)
                (if-let ((root (locate-dominating-file dir
                                                       (lambda (dir)
                                                         (condition-case nil
                                                             (directory-files dir nil (wildcard-to-regexp root-marker) t)
                                                           (file-missing nil))))))
                    (list root properties))))
            monorepo-root-markers))

(defun monorepo--normalize-root-marker (root-marker)
  (cl-etypecase root-marker
    (string
     (list root-marker nil))
    (symbol
     (list root-marker nil))
    (list
     root-marker)))

(cl-defmethod project-root ((project (head monorepo)))
  (nth 1 project))

(cl-defmethod project-files ((project (head monorepo)) &optional dirs)
  (mapcan (lambda (dir)
            (monorepo--project-files-in-directory project dir))
          (or dirs (list (project-root project)))))

(defun monorepo--project-files-in-directory (project dir)
  (let* ((properties (nth 2 project))
         (ignores (cdr (assoc 'ignores properties))))
    (project--files-in-directory dir ignores)))

(provide 'monorepo)
