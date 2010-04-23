;;;; context.lisp
;;;;
;;;; This file is part of the RESTAS library, released under Lisp-LGPL.
;;;; See file COPYING for details.
;;;;
;;;; Author: Moskvitin Andrey <archimag@gmail.com>


(in-package :restas)

(defclass restas-context ()
  ((vars :initarg :vars :initform nil :accessor context-vars)
   (values :initarg :values :initform nil :accessor context-values)))


(defun context-add-variable (context symbol &optional value)
    (push symbol
          (context-vars context))
    (push (or value
              (symbol-value symbol))
          (context-values context)))

(defun context-remove-variable (context symbol)
  (let ((pos (position symbol
                       (context-vars context))))
    (when pos
      (flet ((remove-n (list)
               (concatenate 'list
                            (subseq list 0 pos)
                            (subseq list (1+ pos)))))
        (setf (context-vars context)
              (remove-n (context-vars context)))
        (setf (context-values context)
              (remove-n (context-values context)))))))

(defun context-symbol-value (context symbol)
  (let ((pos (position symbol
                       (context-vars context))))
    (if pos
        (nth pos (context-values context))
        (symbol-value symbol))))

(defun (setf context-symbol-value) (newval context symbol)
  (let ((pos (position symbol
                       (context-vars context))))
    (if pos
        (setf (nth pos
                   (context-values context))
              newval)
        (context-add-variable context symbol newval))))

(defmacro make-context (&body bindings)
  `(let ((vars)
         (values))
     (iter (for (symbol value) in ',bindings)
           (push symbol vars)
           (push (eval value) values))
     (make-instance 'restas-context
                    :vars vars
                    :values values)))

(defmacro with-context (context &body body)
  (let ((cntx (gensym)))
    `(let ((,cntx ,context))
       (progv (context-vars ,cntx) (context-values ,cntx)
         ,@body))))
           
