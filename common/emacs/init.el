;;; init.el --- -*- lexical-binding: t; coding: utf-8; -*-

;;; Commentary:
;;
;; Emacs - A Self-Defined, Fast and Fancy Emacs Configuration.
;;

;;; References:
;; https://github.com/seagle0128/.emacs.d
;; https://github.com/bbatsov/prelude
;; https://github.com/redguardtoo/emacs.d
;; https://github.com/manateelazycat/lazycat-emacs
;; https://github.com/MiniApollo/kickstart.emacs
;; https://github.com/doomemacs/doomemacs
;; https://github.com/purcell/emacs.d
;; https://github.com/SystemCrafters/crafted-emacs

;;; Code:

(use-package use-package
  :custom
  (use-package-verbose t)
  (use-package-always-ensure t)
  (use-package-always-defer t)
  (use-package-expand-minimally t)
  (use-package-enable-imenu-support t))

(use-package package
  :ensure nil
  :custom
  (package-enable-at-startup nil)
  :config
  (when (or (featurep 'esup-child)
            (daemonp)
            noninteractive)
    (package-initialize))
  (setq package-check-signature nil)
  (setq package-quickstart t)
  (setq package-archives '(("melpa" . "https://melpa.org/packages/")
                           ;; ("elpa-devel" . "https://elpa.gnu.org/devel/")
                           ;; ("org" . "https://orgmode.org/elpa/")
                           ;; ("marmalade" . "http://marmalade-repo.jrg/packages/")
                           ;; ("melpa-stable" . "https://stable.melpa.org/packages/")
                           ;; ("jcs-elpa" . "https://jcs-emacs.github.io/jcs-elpa/packages/")
                           ("gnu" . "https://elpa.gnu.org/packages/")
                           ("nongnu" . "https://elpa.nongnu.org/nongnu/"))))

(use-package emacs
  :ensure nil
  :config
  (setq gc-cons-threshold most-positive-fixnum)
  (setq gc-cons-percentage 0.6)
  (setq frame-inhibit-implied-resize t)
  (setq frame-resize-pixelwise t)
  (setq use-file-dialog nil)
  (setq use-dialog-box nil)
  (setq scroll-step 1)
  (setq scroll-margin 0)
  (setq scroll-conservatively 10000)
  (setq auto-window-vscroll nil)
  (setq scroll-preserve-screen-position t)
  (setq-default read-process-output-max 1048576)
  (setq-default max-mini-window-height 0.4)
  (setq-default read-buffer-completion-ignore-case t)
  (setq-default cursor-in-non-selected-windows nil)
  (setq-default highlight-nonselected-windows nil)
  (setq-default bidi-display-reordering nil)
  (setq-default bidi-inhibit-bpa t)
  (setq-default long-line-threshold 500)
  (setq-default large-hscroll-threshold 500)
  (setq-default fast-but-imprecise-scrolling t)
  (setq-default inhibit-compacting-font-caches t)
  (setq-default read-process-output-max (* 64 1024))
  (setq-default highlight-nonselected-windows nil)
  (setq-default redisplay-skip-fontification-on-input t)
  (setq-default cursor-in-non-selected-windows nil)
  (setq-default enable-recursive-minibuffers t)
  (setq-default bidi-paragraph-direction 'left-to-right)
  (setq-default tab-width 2)
  (setq-default truncate-lines t)
  (setq-default completion-ignore-case t)
  (setq-default resize-mini-windows t)
  (setq-default use-short-answers t)
  (setq-default default-frame-alist
                '((menu-bar-lines . 0)
                  (tool-bar-lines . 0)
                  (vertical-scroll-bars)
                  (horizontal-scroll-bars))))

(use-package ns-win
  :ensure nil
  :when (eq system-type 'darwin)
  :config
  (setq mac-option-modifier 'meta)
  (setq mac-command-modifier 'super))

(use-package startup
  :ensure nil
  :hook
  (window-setup . (lambda ()
                    (cl-loop for font in '("JetbrainsMono Nerd Font" "SF Mono" "Monaco" "Menlo" "Consolas")
                             when (find-font (font-spec :name font))
                             return (set-face-attribute 'default nil :family font :height 140))))
  :custom
  (auto-save-list-file-prefix nil)
  (initial-major-mode 'fundamental-mode)
  (inhibit-startup-screen t)
  (inhibit-startup-message t)
  (inhibit-default-init t)
  (initial-scratch-message (concat ";; Happy hacking, " user-login-name " - Emacs ♥ you!\n\n")))

(use-package cus-edit
	:ensure nil
	:custom
	(custom-file (locate-user-emacs-file "custom.el")))

(use-package which-key
	:ensure nil
  :hook
  (after-init . which-key-mode)
	:config
  (setq which-key-show-early-on-C-h t)
  (setq which-key-separator " → " )
  (setq which-key-idle-delay 0.3)
  (setq which-key-idle-secondary-delay 0.01)
  (setq which-key-popup-type 'side-window)
  (setq which-key-side-window-location 'bottom)
  (setq which-key-side-window-max-width 0.33)
  (setq which-key-side-window-max-height 0.25)
  (setq which-key-max-description-length 30))

(use-package simple
  :ensure nil
  :hook
  (prog-mode . column-number-mode)
  (prog-mode . line-number-mode)
  (prog-mode . size-indication-mode)
  :config
  (setq-default indent-tabs-mode nil)
  (setq blink-matching-paren-highlight-offscreen t)
  (setq-default idle-update-delay 1.0))

(use-package display-line-numbers
  :ensure nil
  :hook
  ((prog-mode
    yaml-mode
    conf-mode) . display-line-numbers-mode)
  :config
  (setq display-line-numbers-width-start t))

(use-package frame
  :ensure nil
  :hook
  (after-init . blink-cursor-mode)
  (window-setup . window-divider-mode)
  :config
  (setq blink-cursor-blinks 0)
  (setq blink-cursor-interval 0.3)
  (setq window-divider-default-places t)
  (setq window-divider-default-right-width 1)
  (setq window-divider-default-bottom-width 1))

(use-package files
  :ensure nil
  :hook (after-init . auto-save-visited-mode)
  :config
  (setq auto-save-default nil)
  (setq make-backup-files nil)
  (setq auto-mode-case-fold nil))

(use-package autorevert
  :ensure nil
  :hook (after-init . global-auto-revert-mode))

(use-package display-fill-column-indicator
  :ensure nil
  :hook (prog-mode . display-fill-column-indicator-mode)
  :config
  (setq-default display-fill-column-indicator-column 80))

(use-package elec-pair
  :ensure nil
  :hook (prog-mode . electric-pair-mode))

(use-package ibuffer
  :ensure nil
  :bind (("C-x C-b" . ibuffer)))

(use-package dired
  :ensure nil
  :config
  (setq dired-dwim-target t)
  (setq dired-listing-switches "-alGhv")
  (setq dired-recursive-copies 'always)
  (setq dired-kill-when-opening-new-dired-buffer t))

(use-package whitespace
  :ensure nil
  :hook (prog-mode . whitespace-mode)
  :config
  (setq whitespace-style '(trailing face)))

(use-package so-long
  :ensure nil
  :hook (after-init . global-so-long-mode))

(use-package delsel
  :ensure nil
  :hook (after-init . delete-selection-mode))

(use-package paren
  :ensure nil
  :hook (after-init . show-paren-mode)
  :config
  (setq show-paren-when-point-inside-paren t)
  (setq show-paren-when-point-in-periphery t)
  (setq show-paren-context-when-offscreen t)
  (setq show-paren-delay 0.2))

(use-package hl-line
  :ensure nil
  :hook (prog-mode . hl-line-mode))

(use-package saveplace
  :ensure nil
  :hook (after-init . save-place-mode))

(use-package minibuffer
  :ensure nil
  :hook (after-init . minibuffer-depth-indicate-mode)
  :config
  (setq read-file-name-completion-ignore-case t))

(use-package treesit
  :ensure nil
  :defer 10
  :config
  (setq treesit-language-source-alist
        '((bash . ("https://github.com/tree-sitter/tree-sitter-bash"))
          (c . ("https://github.com/tree-sitter/tree-sitter-c"))
          (cpp . ("https://github.com/tree-sitter/tree-sitter-cpp"))
          (css . ("https://github.com/tree-sitter/tree-sitter-css"))
          (cmake . ("https://github.com/uyha/tree-sitter-cmake"))
          (csharp . ("https://github.com/tree-sitter/tree-sitter-c-sharp.git"))
          (dockerfile . ("https://github.com/camdencheek/tree-sitter-dockerfile"))
          (elisp . ("https://github.com/Wilfred/tree-sitter-elisp"))
          (elixir "https://github.com/elixir-lang/tree-sitter-elixir" "main" "src" nil nil)
          (go . ("https://github.com/tree-sitter/tree-sitter-go"))
          (gomod . ("https://github.com/camdencheek/tree-sitter-go-mod.git"))
          (haskell "https://github.com/tree-sitter/tree-sitter-haskell" "master" "src" nil nil)
          (html . ("https://github.com/tree-sitter/tree-sitter-html"))
          (java . ("https://github.com/tree-sitter/tree-sitter-java.git"))
          (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript"))
          (json . ("https://github.com/tree-sitter/tree-sitter-json"))
          (lua . ("https://github.com/Azganoth/tree-sitter-lua"))
          (make . ("https://github.com/alemuller/tree-sitter-make"))
          (markdown . ("https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown/src"))
          (markdown-inline . ("https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown-inline/src"))
          (ocaml . ("https://github.com/tree-sitter/tree-sitter-ocaml" nil "ocaml/src"))
          (org . ("https://github.com/milisims/tree-sitter-org"))
          (python . ("https://github.com/tree-sitter/tree-sitter-python"))
          (php . ("https://github.com/tree-sitter/tree-sitter-php"))
          (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript" nil "typescript/src"))
          (tsx . ("https://github.com/tree-sitter/tree-sitter-typescript" nil "tsx/src"))
          (ruby . ("https://github.com/tree-sitter/tree-sitter-ruby"))
          (rust . ("https://github.com/tree-sitter/tree-sitter-rust"))
          (sql . ("https://github.com/m-novikov/tree-sitter-sql"))
          (scala "https://github.com/tree-sitter/tree-sitter-scala" "master" "src" nil nil)
          (toml "https://github.com/tree-sitter/tree-sitter-toml" "master" "src" nil nil)
          (vue . ("https://github.com/merico-dev/tree-sitter-vue"))
          (kotlin . ("https://github.com/fwcd/tree-sitter-kotlin"))
          (yaml . ("https://github.com/ikatyang/tree-sitter-yaml"))
          (zig . ("https://github.com/GrayJack/tree-sitter-zig"))
          (clojure . ("https://github.com/sogaiu/tree-sitter-clojure"))
          (nix . ("https://github.com/nix-community/nix-ts-mode"))
          (mojo . ("https://github.com/HerringtonDarkholme/tree-sitter-mojo")))))

(use-package prog-mode
  :ensure nil
  :hook (prog-mode . prettify-symbols-mode)
  :config
  (setq prettify-symbols-unprettify-at-point 'right-edge))

(use-package flymake
  :ensure nil
  :hook (prog-mode . flymake-mode)
  :bind
  (("M-n" . flymake-goto-next-error)
   ("M-p" . flymake-goto-prev-error))
  :config
  (setq flymake-fringe-indicator-position 'right-fringe))

(use-package evil
  :hook
  (after-init . evil-mode)
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (setq evil-normal-state-cursor 'box)
  (setq evil-emacs-state-cursor 'box)
  (setq evil-insert-state-cursor 'bar)
  (setq evil-visual-state-cursor 'hollow))

(use-package evil-collection
  :defer 2
  :after (evil)
  :config
  (evil-collection-init))

(use-package evil-escape
  :hook (evil-mode . evil-escape-mode)
  :config
  (setq evil-escape-key-sequence "jk")
  (setq evil-escape-delay 0.2))

(use-package evil-nerd-commenter
  :after (evil)
  :bind
  (:map evil-normal-state-map
        (("gcc" . evilnc-comment-or-uncomment-lines)))
  (:map evil-visual-state-map
        (("gc" . evilnc-comment-or-uncomment-lines))))

(provide 'init)
;;; Local Variables:
;;; no-byte-compile: t
;;; no-native-compile: t
;;; no-update-autoloads: t
;;; End:
;;; init.el ends here
