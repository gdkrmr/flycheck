;;; global-mode-test.el --- Tests for Flycheck global mode  -*- lexical-binding: t; -*-

;; Copyright (C) 2013  Sebastian Wiesner

;; Author: Sebastian Wiesner <lunaryorn@gmail.com>
;; URL: https://github.com/flycheck/flycheck

;; This file is not part of GNU Emacs.

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

;; Tests for `global-flycheck-mode'.

;;; Code:

(require 'test-helper)
(require 'epa-file)

(ert-deftest flycheck-may-enable-mode/not-in-ephemeral-buffers ()
  (with-temp-buffer
    (should-not (flycheck-may-enable-mode)))
  (with-temp-buffer
    (setq buffer-file-name "foo")
    (emacs-lisp-mode)
    (should (flycheck-get-checker-for-buffer))
    (rename-buffer " foo")
    (should (string= (buffer-name) " foo"))
    (should-not (flycheck-may-enable-mode))))

(ert-deftest flycheck-may-enable-mode/not-in-encrypted-files ()
  (let* ((filename (flycheck-testsuite-resource-filename "encrypted-file.el.gpg"))
         ;; Tell EPA about our passphrase
         (epa-file-cache-passphrase-for-symmetric-encryption t)
         (epa-file-passphrase-alist (list (cons filename "foo"))))
    (flycheck-testsuite-with-resource-buffer filename
      (emacs-lisp-mode)
      (should (flycheck-get-checker-for-buffer))
      (should-not (flycheck-may-enable-mode)))))

(ert-deftest flycheck-may-enable-mode/does-not-enable-in-tramp-buffers ()
  :expected-result :failed
  (error "Implement me: Find a dummy tramp backend to use for this test!"))

(ert-deftest flycheck-may-enable-mode/not-if-no-checker-is-found ()
  (with-temp-buffer
    (setq buffer-file-name "foo")
    (rename-buffer "foo")
    (text-mode)
    (should-not (s-starts-with? " " (buffer-name)))
    (should-not (flycheck-get-checker-for-buffer))
    (should-not (flycheck-may-enable-mode))))

(ert-deftest flycheck-may-enable-mode/checker-found ()
  (with-temp-buffer
    (setq buffer-file-name "foo")
    (rename-buffer "foo")
    (emacs-lisp-mode)
    (should (flycheck-get-checker-for-buffer))
    (should (flycheck-may-enable-mode))))

(ert-deftest global-flycheck-mode/does-not-enable-in-ephemeral-buffers ()
  (flycheck-with-global-mode
    (with-temp-buffer
      (setq buffer-file-name "foo")
      (rename-buffer " foo")
      (emacs-lisp-mode)
      (should-not flycheck-mode))))

(ert-deftest global-flycheck-mode/does-not-enable-in-encrypted-file ()
  (let* ((filename (flycheck-testsuite-resource-filename "encrypted-file.el.gpg"))
         ;; Tell EPA about our passphrase
         (epa-file-cache-passphrase-for-symmetric-encryption t)
         (epa-file-passphrase-alist (list (cons filename "foo"))))
    (flycheck-with-global-mode
      (flycheck-testsuite-with-resource-buffer filename
        (emacs-lisp-mode)
        (should-not flycheck-mode)))))

(ert-deftest global-flycheck-mode/does-not-enable-if-no-checker-is-found ()
  (flycheck-with-global-mode
    (with-temp-buffer
      (rename-buffer "foo")
      (text-mode)
      (should-not flycheck-mode))))

(ert-deftest global-flycheck-mode/checker-found ()
  (flycheck-with-global-mode
    (with-temp-buffer
      (setq buffer-file-name "foo")
      (rename-buffer "foo")
      (emacs-lisp-mode)
      (should flycheck-mode))))

;;; global-mode-test.el ends here
