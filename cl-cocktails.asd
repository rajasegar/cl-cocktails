(defsystem "cl-cocktails"
  :version "0.1.0"
  :author "Rajasegar Chandran"
  :license ""
  :depends-on ("clack"
               "lack"
               "caveman2"
               "envy"
               "uiop"
	       "cl-ppcre"

               ;; HTML Template
               "djula"

               ;; for DB
               "datafly"
	       ;; Ajax
	       "dexador"
	       ;; json
	       "cl-json"

	       ;; url helpers
	       "quri")
  :components ((:module "src"
                :components
                ((:file "main" :depends-on ("config" "view" "db"))
                 (:file "web" :depends-on ("view"))
                 (:file "view" :depends-on ("config"))
                 (:file "db" :depends-on ("config"))
                 (:file "config"))))
  :description ""
  :in-order-to ((test-op (test-op "cl-cocktails-test"))))
