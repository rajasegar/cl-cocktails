(defsystem "cl-cocktails-test"
  :defsystem-depends-on ("prove-asdf")
  :author "Rajasegar Chandran"
  :license ""
  :depends-on ("cl-cocktails"
               "prove")
  :components ((:module "tests"
                :components
                ((:test-file "cl-cocktails"))))
  :description "Test system for cl-cocktails"
  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
