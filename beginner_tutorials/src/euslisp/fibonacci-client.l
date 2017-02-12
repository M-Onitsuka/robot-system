#! /usr/bin/env roseus

(ros::load-ros-manifest "roseus")
(ros::load-ros-manifest "actionlib_tutorials")

(ros::roseus "fibonacci_client")

(defun fibonacci (n)
  (if (< n 2)
      n
    (+ (fibonacci (- n 1)) (fibonacci (- n 2)))))

(defun fibonacci-client (&optional (order 10))
  (let (goal)
    (if (not (boundp '*c*))
	(setq *c* (instance ros::simple-action-client :init
			    "fibonacci" actionlib_tutorials::FibonacciAction)))
    (warning-message 2 ";; ~A wait-for-server~%" (unix::getpid))
    (send *c* :wait-for-server)
    (setq goal (instance actionlib_tutorials::FibonacciActionGoal :init))
    (send goal :goal :order order)
    (send *c* :send-goal goal)
    (send *c* :send-goal goal :feedback-cb
	  #'(lambda (msg) (print (list 'feedback (send msg :feedback :sequence)))))
    (unless (send *c* :wait-for-result :timeout 5)
      (send *c* :cancel-goal))

    (warning-message 2 ";; ~A wait-for-result~%" (unix::getpid))
    (send *c* :wait-for-result)
    (warning-message 2 ";; ~A result > ~A~%"
		     (unix::getpid) (send (send *c* :get-result) :sequence))
    (send (send *c* :get-result) :sequence)
    ))

(print (fibonacci 10))
(fibonacci-client 10)
