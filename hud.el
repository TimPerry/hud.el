;;; hud.el --- Hot UK Deals reader                     -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Tim Perry

;; Author: Tim Perry <tim.r.perry@gmail.com>
;; Keywords: lisp
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Used to read hot uk deals.
;;
;; To see the hottest deals `M-x` then `hud-show-hot-deals`
;;
;; No key bindings are provided by default.
;; 

;;; Code:

;; Dependencies
(require 'request)

;;; Variables
(defvar hud-endpoint
  "http://api.hotukdeals.com/rest_api/v2/")

(defvar hud-deals nil)

;;; Functions

;;;###autoload
(defun hud-load-deal ()
  "Load the select deal"
  (interactive)
  (toggle-read-only)
  (browse-url (assoc-default 'deal_link (aref hud-deals (1- (line-number-at-pos))))))

;;;###autoload
(defun hud-show-hot-deals ()
  "Show HUD hot deals."
  (interactive)
  (if (get-buffer "hud-hot-deals")
      (progn (toggle-read-only)
	     (erase-buffer)))
  (set-buffer (get-buffer-create "hud-hot-deals"))
  (pop-to-buffer "hud-hot-deals")
  (insert "Loading please wait...")
  (hud-minor-mode)
  (request
   hud-endpoint
   :params '(("output" . "json") ("key" . "cdf3ead1c5b7f68cb2a575ea45b857be"))
   :parser 'json-read
   :error (function*
	   (lambda (&rest args &key error-thrown &allow-other-keys)
	     (erase-buffer)
	     (insert "Got error: %S" error-thrown)))
   :success (function*
	     (lambda (&key data &allow-other-keys)
	       (erase-buffer)
	       (setq hud-deals (assoc-default 'items (assoc-default 'deals data)))
	       (loop for deal across hud-deals
		     do (insert (format "* %s\n" (assoc-default 'title deal))))
	       (read-only-mode)))))

;;; Modes

(define-minor-mode hud-minor-mode
  "Minor mode for HUD package"
  :lighter "HUD"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "<return>") 'hud-load-deal)
            map))

(provide 'hud)
;;; hud.el ends here
