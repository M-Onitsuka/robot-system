#!/usr/bin/env roseus

(ros::load-ros-manifest "roseus")

(defun add-two-ints (req)
  (let ((m (send req :response)))
    (format *error-output* "Returning [~D + ~D = ~D]~%"
	    (send req :a) (send req :b)
	    (+ (send req :a) (send req :b)))
    (send m :sum (+ (send req :a) (send req :b)))
    m))

(ros::roseus "add_two_ints_server")
(ros::advertise-service "add_two_ints" roseus::AddTwoInts #'add-two-ints)
(do-until-key
 (ros::spin-once))
