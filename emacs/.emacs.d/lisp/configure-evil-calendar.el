;; -*- lexical-binding: t; -*-

(progn ;; calendar
  (require 'evil)
  (require 'calendar)

  (defun evil-collection-calendar-setup ()
    "Set up Evil bindings for Calendar."
    (evil-set-initial-state 'calendar-mode 'normal)

    (evil-define-key 'normal calendar-mode-map
      "h" #'calendar-backward-day
      "j" #'calendar-forward-week
      "k" #'calendar-backward-week
      "l" #'calendar-forward-day
      "0" #'calendar-beginning-of-week
      "$" #'calendar-end-of-week
      "[[" #'calendar-backward-year
      "]]" #'calendar-forward-year
      "{" #'calendar-backward-month
      "}" #'calendar-forward-month
      (kbd "C-k") #'calendar-backward-month
      (kbd "C-j") #'calendar-forward-month
      "." #'calendar-goto-today
      "gd" #'calendar-goto-date
      "gr" #'calendar-redraw
      "q" #'calendar-exit))

  (evil-collection-calendar-setup))

(provide 'configure-evil-calendar)
