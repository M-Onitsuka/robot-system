#!/usr/bin/env roseus

(ros::load-ros-manifest "roseus")

(ros::roseus "add_two_ints_client")
(ros::wait-for-service "add_two_ints")
(dotimes (i 100)
  (setq req (instance roseus::AddTwoIntsRequest :init))
  (send req :a (random 10))
  (send req :b (random 20))
  (setq before (ros::time-now))
  (setq res (ros::service-call "add_two_ints" req))
  (setq after (ros::time-now))
  (format t "~D + ~D = ~D~ (~A sec)~%" (send req :a) (send req :b) (send res :sum)
	  (send (ros::time- after before) :to-sec))
  (unix:usleep 100000))

(exit)
