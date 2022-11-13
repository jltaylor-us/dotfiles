;; ____________________________________________________________________________
;; Aquamacs custom-file warning:
;; Warning: After loading this .emacs file, Aquamacs will also load
;; customizations from `custom-file' (customizations.el). Any settings there
;; will override those made here.
;; Consider moving your startup settings to the Preferences.el file, which
;; is loaded after `custom-file':
;; ~/Library/Preferences/Aquamacs Emacs/Preferences
;; _____________________________________________________________________________

;; global configuration

(setq load-path (append '("~/Library/Emacs"
                          ; package sub-paths can go here.  At various times
                          ; I've the following
			  ;"~/Library/Emacs/lout-mode"
			  ;"~/Library/Emacs/mmm-mode"
			  ;"~/Library/Emacs/psgml"
                          ;"~/Library/Emacs/nxml-mode"
			  ) load-path))

(when (boundp 'tool-bar-mode) (tool-bar-mode 0))
(global-font-lock-mode 1)
(transient-mark-mode t)
(delete-selection-mode 0)

;(setq show-paren-style 'mixed) ;other choices are parenthesis and expression

(when (and (boundp 'aquamacs-version) (locate-library "color-theme"))
  (require 'color-theme)
  (color-theme-initialize)
  (load "color-theme-jamie.el")
  (color-theme-jamie))
;      (color-theme-charcoal-black)

;(setq explicit-bash-args '("-il"))
(setq-default indent-tabs-mode nil)
(setq-default fill-column 74)

;; Enable versioning with default values (keep five last versions, I think!)
(setq version-control t)

;; Save all backup file in this directory.
(setq backup-directory-alist (quote ((".*" . "~/.emacs_backups/"))))

;; don't prompt before deleting excess backup versions
(setq delete-old-versions t)

;; scheme configuration

(load "iuscheme")
(autoload 'scheme-mode "iuscheme" "Major mode for Scheme." t)
(autoload 'run-scheme "iuscheme" "Switch to interactive Scheme buffer." t)
(setq auto-mode-alist (cons '("\\.ss" . scheme-mode) auto-mode-alist))
(defvar close-current-sexp-alist
  '((?\( ?\)) (?\[ ?\]) (?\{ ?\}))
  "Alist of paired delimiter characters for close-current-sexp")

(defun close-current-sexp () 
  "Close the current sexp with the appropriate delimiter (if it can be determined)"
  (interactive)
  (let* ((oldpos (point))
	 (opendelim
	  (condition-case ()
	      (save-excursion
		(save-restriction
		  ; restrict distance to search as in blink-matching-open
		  (if blink-matching-paren-distance
		      (narrow-to-region
		       (max (minibuffer-prompt-end) ;(point-min) unless minibuf.
			    (- (point) blink-matching-paren-distance))
		       oldpos))
		  (backward-up-list 1)
		  (char-after)))
	    (error nil)))
	 (closedelim-pair (assq opendelim close-current-sexp-alist))
	 )
    (if closedelim-pair
	(insert (cadr closedelim-pair))
      (insert last-command-char))
    (blink-matching-open)
    ))
;;(defun replace-containing-sexp ()
;;  "Replace the containing sexp with the sexp to the right of the cursor"
;;  (interactive)
;;  (kill-sexp)
;;  (backward-up-list)
;;  (yank)
;;  ;;(cua-paste)
;;  (kill-sexp)
;;  (backward-sexp)
;;  (indent-sexp))
(fset 'replace-containing-sexp "\C-\M-k\C-\M-u\C-y\C-\M-k\C-\M-b\C-\M-q")
(add-hook 'scheme-mode-hook 'my-scheme-mode-hook)
(defun my-scheme-mode-hook ()
  (setq scheme-indentation-style 'iu)
  (define-key scheme-mode-map "\n" 'newline)
  (define-key scheme-mode-map "\r" 'newline-and-indent)
  (define-key scheme-mode-map ")" 'close-current-sexp)
  (define-key scheme-mode-map "]" 'close-current-sexp)
  (define-key scheme-mode-map "\C-\M-j" 'replace-containing-sexp))
(defun scheme-add-keywords (face-name keyword-list)
  (let ((keyword-regexp (concat "(\\("
				(regexp-opt keyword-list)
				"\\)[ \t\n]")))
    (font-lock-add-keywords 'scheme-mode
			    `((,keyword-regexp 1 ',face-name)))))
(scheme-add-keywords 
 'font-lock-keyword-face
 '("module" "import" "export" "include" "when" "unless" "values"))
(font-lock-add-keywords 
 'scheme-mode
 '(("(\\(define-record\\)\\s-+\\(\\sw+\\)" (1 font-lock-keyword-face) (2 font-lock-variable-name-face))
   ("!!!" . font-lock-warning-face)
   ))

;(setq scheme-program-name "petite")
(setq scheme-program-name "scheme")

;; elisp
(defun my-emacs-lisp-mode-hook ()
  (define-key emacs-lisp-mode-map "\r" 'newline-and-indent))
(add-hook 'emacs-list-mode-hook 'my-emacs-lisp-mode-hook)

;; -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
;; comment helpers
(defun repeat-to-column (&optional str to-col)
  "Insert enough copies of the given string to reach to-col"
  (interactive 
   (if current-prefix-arg
       (list (read-string "Insert string: " "-")
             (string-to-number (read-string "To column: " (number-to-string fill-column))))
     (list "-" fill-column)))
  (unless (< 0 (length str)) (error "Zero length string"))
  (when (< (current-column) (or to-col fill-column))
    (insert str)
    (repeat-to-column str to-col)))
(defun insert-comment-header-1 ()
  "Insert a level one header"
  (interactive)
  (repeat-to-column "-+"))


(defun align-field-decls ()
  "Insert spaces after the first text on a line in order to line up everything else"
  (interactive)
  (align-regexp (region-beginning) (region-end) "^\\s-*[^ \t\r\n]+\\([ \t]+\\)\\S-+" 1 align-default-spacing nil))

;; lout mode
;(autoload 'lout-mode "lout-mode" "Major mode for editing Lout text" t)
;(setq auto-mode-alist
;      (append '(("\\.lout\\'" . lout-mode)) auto-mode-alist))


;; psgml mode
;(autoload 'sgml-mode "psgml" "Major mode to edit SGML files." t)
;(autoload 'xml-mode "psgml" "Major mode to edit XML files." t)

;; nxml-mode
;(load "nxml/autostart.el")
(defun my-nxml-mode-hook ()
  (define-key nxml-mode-map "\r" 'newline-and-indent)
  (abbrev-mode 1)
  (setq fill-column 120)
  (message "My nxml-mode customizations loaded"))
(add-hook 'nxml-mode-hook 'my-nxml-mode-hook)
;(load "rng-auto.el")
(add-to-list 'auto-mode-alist
             (cons (concat "\\." (regexp-opt '("xml" "xsd" "sch" "rng" "xslt" "svg" "rss") t) "\\'")
                   'nxml-mode))
(setq magic-mode-alist
      (cons '("<\\?xml " . nxml-mode)
            (cons '("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML" . nxml-mode)
                  magic-mode-alist)))
(fset 'xml-mode 'nxml-mode)
(setq nxml-slash-auto-complete-flag t)
(setq nxml-sexp-element-flag t)
(setq nxhtml-skip-welcome t)


;; javascript mode
;(add-to-list 'auto-mode-alist '("\\.js\\'" . javascript-mode))
;(autoload 'javascript-mode "javascript" nil t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fancy HTML (jsp) editing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; configure css-mode
;(autoload 'css-mode "css-mode")
;(add-to-list 'auto-mode-alist '("\\.css\\'" . css-mode))
;(setq cssm-indent-function #'cssm-c-style-indenter)
;(setq cssm-indent-level '2)
;;;
;(require 'mmm-mode)
;(setq mmm-global-mode 'maybe)
;;;
;;; set up an mmm group for fancy html editing
;(mmm-add-group
; 'fancy-html
; '(
;   (html-css-attribute
;    :submode css-mode
;    :face mmm-declaration-submode-face
;    :front "style=\""
;    :back "\"")
;   (jsp-code
;    :submode java-mode
;    :match-face (("<%!" . mmm-declaration-submode-face)
;                 ("<%=" . mmm-output-submode-face)
;                 ("<%"  . mmm-code-submode-face))
;    :front "<%[!=]?"
;    :back "%>"
;    :insert ((?% jsp-code nil @ "<%" @ " " _ " " @ "%>" @)
;             (?! jsp-declaration nil @ "<%!" @ " " _ " " @ "%>" @)
;             (?= jsp-expression nil @ "<%=" @ " " _ " " @ "%>" @))
;    )
;   (jsp-directive
;    :submode text-mode
;    :face mmm-special-submode-face
;    :front "<%@"
;    :back "%>"
;    :insert ((?@ jsp-directive nil @ "<%@" @ " " _ " " @ "%>" @))
;    )
;   ))
;;;
;;; What files to invoke the new html-mode for?
;(add-to-list 'auto-mode-alist '("\\.[sj]?html?\\'" . html-mode))
;(add-to-list 'auto-mode-alist '("\\.jsp[f]?\\'" . html-mode))
;;;
;;; What features should be turned on in this html-mode?
;(add-to-list 'mmm-mode-ext-classes-alist '(html-mode nil html-js))
;(add-to-list 'mmm-mode-ext-classes-alist '(html-mode nil embedded-css))
;(add-to-list 'mmm-mode-ext-classes-alist '(html-mode nil fancy-html))
;
;;; Not exactly related to editing HTML: enable editing help with mouse-3 in all sgml files
;(defun go-bind-markup-menu-to-mouse3 ()
;  (define-key sgml-mode-map [(down-mouse-3)] 'sgml-tags-menu))
;;;
;(add-hook 'sgml-mode-hook 'go-bind-markup-menu-to-mouse3)
;

(global-set-key "\C-\\" 'call-last-kbd-macro)

;;; specifically for Aquamacs
(when (boundp 'osx-key-mode-map) 
  (define-key osx-key-mode-map [end] 'move-end-of-line)
  (define-key osx-key-mode-map [home] 'move-beginning-of-line)
  (define-key osx-key-mode-map "\M-w" 'clipboard-kill-ring-save)
  (define-key osx-key-mode-map "\C-w" 'clipboard-kill-region))

;; This disables the "helpful" feature of aquamacs that makes the mark remain
;; active after performing a copy.
(load "emacs-lisp/advice")
(when (ad-is-advised 'cua-copy-region)
  (defadvice cua-copy-region (around keep-region activate) ad-do-it))
;; previous code that no longer works in Aquamacs 3
;;(when (ad-is-advised 'cua-copy-region)
;;  (ad-disable-advice 'cua-copy-region 'around 'keep-region)
;;  (ad-activate 'cua-copy-region))


;;; ---- Does not appear to be required for Aquamacs ----
;(add-to-list 'default-frame-alist '(height . 40))
;(add-to-list 'default-frame-alist '(width . 120))
;;;; MacOS X specific stuff
;(setq mac-command-key-is-meta nil) ; for yecad emacs distribution
;; for CarbonEmacs distribution
;(setq mac-option-modifier 'meta)
;(setq mac-control-modifier 'ctrl)
;(setq mac-command-modifier 'alt)
;
;;; Define the return key to avoid problems on MacOS X
;(define-key function-key-map [return] [13])
;
;(global-set-key [(alt a)] 'mark-whole-buffer)
;(global-set-key [(alt v)] 'yank)
;(global-set-key [(alt c)] 'kill-ring-save)
;(global-set-key [(alt x)] 'kill-region)
;(global-set-key [(alt s)] 'save-buffer)
;(global-set-key [(alt l)] 'goto-line)
;(global-set-key [(alt o)] 'find-file)
;(global-set-key [(alt f)] 'isearch-forward)
;(global-set-key [(alt g)] 'isearch-repeat-forward)
;(global-set-key [(alt w)]
;                (lambda () (interactive) (kill-buffer (current-buffer))))
;(global-set-key [(alt .)] 'keyboard-quit)
;

;;; ----- (end comment out for Aquamacs) ----

;; I disabled this since I want to avoid hitting Cmd-q accidentally.
;(global-set-key [(alt q)] 'save-buffers-kill-emacs)


(put 'narrow-to-region 'disabled nil)

(put 'upcase-region 'disabled nil)

(put 'downcase-region 'disabled nil)

(put 'erase-buffer 'disabled nil)
