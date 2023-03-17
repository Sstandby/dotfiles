;; Disable menu-bar, tool-bar and scroll-bar to increase the usable space.
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
;; Also shrink fringes to 1 pixel.
(fringe-mode 1)

;; Turn on `display-time-mode' if you don't use an external bar.
(setq display-time-default-load-average nil)
(display-time-mode t)

;; You are strongly encouraged to enable something like `ido-mode' to alter
;; the default behavior of 'C-x b', or you will take great pains to switch
;; to or back from a floating frame (remember 'C-x 5 o' if you refuse this
;; proposal however).
;; You may also want to call `exwm-config-ido' later (see below).
(ido-mode 1)

;; Emacs server is not required to run EXWM but it has some interesting uses
;; (see next section).
(server-start)
;;;; Below are configurations for EXWM.

;; Add paths (not required if EXWM is installed from GNU ELPA).
;(add-to-list 'load-path "/path/to/xelb/")
;(add-to-list 'load-path "/path/to/exwm/")

;; Load EXWM.
(require 'exwm)
;; Fix problems with Ido (if you use it).
(require 'exwm-config)
(exwm-config-ido)

;; Set the initial number of workspaces (they can also be created later).
(setq exwm-workspace-number 4)

;; All buffers created in EXWM mode are named "*EXWM*". You may want to
;; change it in `exwm-update-class-hook' and `exwm-update-title-hook', which
;; are run when a new X window class name or title is available.  Here's
;; some advice on this topic:
;; + Always use `exwm-workspace-rename-buffer` to avoid naming conflict.
;; + For applications with multiple windows (e.g. GIMP), the class names of
;    all windows are probably the same.  Using window titles for them makes
;;   more sense.
;; In the following example, we use class names for all windows except for
;; Java applications and GIMP.
(add-hook 'exwm-update-class-hook
          (lambda ()
            (unless (or (string-prefix-p "sun-awt-X11-" exwm-instance-name)
                        (string= "gimp" exwm-instance-name))
              (exwm-workspace-rename-buffer exwm-class-name))))

(add-hook 'exwm-update-title-hook
          (lambda ()
            (when (or (not exwm-instance-name)
                      (string-prefix-p "sun-awt-X11-" exwm-instance-name)
                      (string= "gimp" exwm-instance-name))
              (exwm-workspace-rename-buffer exwm-title))))

;; Global keybindings can be defined with `exwm-input-global-keys'.
;; Here are a few examples:
(setq exwm-input-global-keys
      `(
        ;; Bind "s-r" to exit char-mode and fullscreen mode.
        ;;([?\s-r] . exwm-reset)
        ([?\s-r] . restart-emacs)
        ;; Bind "s-w" to switch workspace interactively.
        ([?\s-w] . exwm-workspace-switch)
        ;; Bind "s-0" to "s-9" to switch to a workspace by its index.
        ,@(mapcar (lambda (i)
                    `(,(kbd (format "s-%d" i)) .
                      (lambda ()
                        (interactive)
                        (exwm-workspace-switch-create ,i))))
                  (number-sequence 0 9))
        ;; Bind "s-&" to launch applications ('M-&' also works if the output
        ;; buffer does not bother you).
        ; ([?\s-f] . (lambda (command)
        ;  (interactive (list (read-shell-command "$ ")))
        ;  (start-process-shell-command command nil command)))
        ;Bind "s-<f2>" to "slock", a simple X display locker.
        ([s-f2] . (lambda ()
        (interactive)
        (start-process "" nil "/usr/bin/slock")))))

;; combinations functions

(defun scrot-scren ()
  "Take a screenshot using scrot and open it in a new buffer."
  (interactive)
  (let* ((filename (concat "/home/mrgatete/Img/Capturas/screenshot-" (format-time-string "%Y-%m-%d-%H-%M-%S") ".png"))
         (cmd (concat "scrot -s " filename))
         (exit-code (call-process-shell-command cmd nil 0)))
    (if (= exit-code 0)
        (progn
          (message "Screenshot saved to %s" filename)
          (find-file-noselect filename)
          (image-mode)
          (switch-to-buffer (buffer-name)))
      (message "Error taking screenshot"))))

(defun start-app (app-name)
  (interactive)
  (start-process-shell-command app-name nil app-name))

(defun create-window ()
  "Create a new window."
  (interactive)
  (select-window (split-window-right)))

;; keyboards combinations

(global-set-key (kbd "C-x C-c") 'save-buffers-kill-emacs)
(define-key exwm-mode-map [?\C-q] #'exwm-input-send-next-key)
(exwm-input-set-key (kbd "s-<return>") (lambda () (interactive)  (create-window)))
(exwm-input-set-key (kbd "s-d") (lambda () (interactive) (delete-window)))

(setq exwm-input-simulation-keys
      '(
        ;; movement
        ([?\C-b] . [left])
        ([?\M-b] . [C-left])
        ([?\C-n] . [down])
        ([?\C-f] . [right])
        ([?\M-f] . [C-right])
        ([?\C-p] . [up])
        ([?\C-a] . [?\C-a])
        ([?\C-e] . [end])
        ([?\M-v] . [prior])
        ([?\C-v] . [next])
        ([?\C-d] . [delete])
        ([?\C-k] . [S-end delete])
        ;; cut/paste.
        ([?\C-k] . [?\C-x])
        ([?\C-j] . [?\C-c])
        ([?\C-v] . [?\C-v])
        ;; search
        ([?\C-s] . [?\C-s])
        ([?\C-f] . [?\C-f])))


;; launch apps

(exwm-input-set-key (kbd "s-p") (lambda () (interactive) (scrot-scren)))
(exwm-input-set-key (kbd "s-k") (lambda () (interactive) (start-app "kitty")))
(exwm-input-set-key (kbd "s-b") (lambda () (interactive) (start-app "qutebrowser")))
(exwm-input-set-key (kbd "s-q") (lambda () (interactive) (kill-this-buffer)))
(exwm-input-set-key (kbd "s-f") (lambda ()
    (interactive)
    (let
      ((rofi "rofi -modi drun,window -show drun -theme /home/mrgatete/.config/rofi/launchers/type-3/style-3.rasi"))
      (call-process-shell-command rofi))))
    (push (elt (kbd "s-f") 0) exwm-input-prefix-keys)

;; windows

(exwm-input-set-key (kbd "C-1") (lambda () (interactive) (split-window-right)))
(exwm-input-set-key (kbd "C-2") (lambda () (interactive) (split-window-below)))
(exwm-input-set-key (kbd "C-3") (lambda () (interactive) (split-window-left)))
(exwm-input-set-key (kbd "C-4") (lambda () (interactive) (split-window-above)))

;; move between buffers in the window

(exwm-input-set-key (kbd "<C-s-left>") 'previous-up)
(exwm-input-set-key (kbd "<C-s-right>") 'next-down)

;; moving between windows

(exwm-input-set-key (kbd "<s-up>") 'windmove-up)
(exwm-input-set-key (kbd "<s-down>") 'windmove-down)
(exwm-input-set-key (kbd "<s-right>") 'windmove-right)
(exwm-input-set-key (kbd "<s-left>") 'windmove-left)

;; You can hide the minibuffer and echo area when they're not used, by
;; uncommenting the following line.
;(setq exwm-workspace-minibuffer-position 'bottom)

;; automatically start together with Exwm in the future (start-compositor) at the
;; hook ef exwm-init-hook
(require 'exwm-randr)
(setq exwm-randr-workspace-output-plist '(0 "VGA1"))
(add-hook 'exwm-randr-screen-change-hook
          (lambda ()
            (start-process-shell-command
             "xrandr" nil "xrandr --output VGA1 --left-of LVDS1 --auto")))
(exwm-randr-enable)

(add-hook 'exwm-init-hook #'(lambda () (start-process-shell-command "picom" nil "picom")))

;; Do not forget to enable EXWM. It will start by itself when things are
;; ready.  You can put it _anywhere_ in your configuration.
(exwm-enable)
