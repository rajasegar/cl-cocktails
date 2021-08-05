(in-package :cl-user)
(defpackage cl-cocktails.web
  (:use :cl
        :caveman2
        :cl-cocktails.config
        :cl-cocktails.view
        :cl-cocktails.db)
  (:export :*web*))
(in-package :cl-cocktails.web)

;; for @route annotation
(syntax:use-syntax :annot)

;;
;; Application

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(clear-routing-rules *web*)

(defvar *alcoholic-options* '("" "Alcoholic" "Non alcoholic" "Optional alcohol"))
(defvar *categories* '(""
		       "Ordinary Drink"
		       "Cocktail"
		       "Cocoa"
		       "Milk / Float / Shake"
		       "Other/Unknown"
		       "Shot"
		       "Coffee / Tea"
		       "Homemade Liqueur"))

;;
;; Routing rules

(defroute "/" ()
  (let ((cocktails (cl-json:decode-json-from-string (dex:get "https://www.thecocktaildb.com/api/json/v1/1/search.php?s="))))
    (print cocktails)
    (render #P"index.html" (list :cocktails (rest (assoc :drinks cocktails))
				 :alcoholics *alcoholic-options*
				 :categories *categories*))))

(defroute "/cocktails/:id" (&key id)
  (let ((cocktail (cl-json:decode-json-from-string (dex:get (concatenate 'string "https://www.thecocktaildb.com/api/json/v1/1/lookup.php?i=" id)))))
    (print (getf  (assoc :drinks cocktail) :drinks))
    (render #P"show.html" (list :cocktail (getf (assoc :drinks cocktail) :drinks)))))

(defroute "/ingredients/:id" (&key id)
  (let ((ingredient (cl-json:decode-json-from-string (dex:get (concatenate 'string "https://www.thecocktaildb.com/api/json/v1/1/lookup.php?iid=" id)))))
    (print ingredient)
    (render #P"ingredients/show.html" (list :ingredient ingredient))))

(defroute "/random" ()
  (let ((cocktail (cl-json:decode-json-from-string (dex:get "https://www.thecocktaildb.com/api/json/v1/1/random.php"))))
    (print cocktail)
    (render #P"show.html" (list :cocktail (getf (assoc :drinks cocktail) :drinks)))))

(defroute "/first-letter/:id" (&key id)
  (let ((cocktails (cl-json:decode-json-from-string (dex:get (concatenate 'string "https://thecocktaildb.com/api/json/v1/1/search.php?f=" id)))))
    (render #P"_cocktail-list.html" (list :cocktails (get (assoc :drinks cocktails) :drinks)))))

;; Get list of ingredients
(defroute "/ingredients" ()
  (let ((ingredients (cl-json:decode-json-from-string (dex:get "https://thecocktaildb.com/api/json/v1/1/list.php?i=list"))))
    (render #P"_ingredients.html" (list :ingredients (assoc :drinks ingredients)))))

;; Get list of glasses
(defroute "/glasses" ()
  (let ((glasses (cl-json:decode-json-from-string (dex:get "https://thecocktaildb.com/api/json/v1/1/list.php?g=list"))))
    (print glasses)
    (render #P"_glasses.html" (list :glasses (assoc :drinks glasses)))))
  

;; filter by ingredient
(defroute ("/filter/ingredient" :method :POST) (&key _parsed)
  (let* ((ingredient (cdr (assoc "ingredient" _parsed :test #'string=)))
	(param "i")
	(value (quri:url-encode ingredient)))
    (filter-cocktails param value)))

;; filter by category
(defroute ("/filter/category" :method :POST) (&key _parsed)
  (let* ((category (cdr (assoc "category" _parsed :test #'string=)))
	(param "c")
	(value (quri:url-encode category)))
    (filter-cocktails param value)))

;; filter by glass
(defroute ("/filter/glass" :method :POST) (&key _parsed)
  (let* ((glass (cdr (assoc "glass" _parsed :test #'string=)))
	(param "g")
	(value (quri:url-encode glass)))
    (filter-cocktails param value)))

;; filter by alchoholic
(defroute ("/filter/alcoholic" :method :POST) (&key _parsed)
  (let* ((alchoholic (cdr (assoc "alcoholic" _parsed :test #'string=)))
	(param "a")
	(value (quri:url-encode alchoholic)))
    (filter-cocktails param value)))

;; filter cocktails
(defun filter-cocktails (param value)
  (let* ((cocktails
	   (cl-json:decode-json-from-string
	    (dex:get
	     (concatenate 'string  "https://thecocktaildb.com/api/json/v1/1/filter.php?"
			  param "=" value)))))
    (render #P"_cocktail-list.html" (list :cocktails (rest (assoc :drinks cocktails))))))
;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
