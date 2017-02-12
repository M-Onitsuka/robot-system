#!/usr/bin/env roseus

(ros::load-ros-manifest "roseus")
(ros::load-ros-manifest "jsk_recognition_msgs")
(ros::load-ros-manifest "image_view2")

(ros::roseus "test")

(load "irteus/demo/sample-robot-model.l")
(setq *robot* (instance sample-robot :init))
(send *robot* :reset-pose)
(objects (list *robot*))

(setq *msg* nil)
(defun color-cb (msg)
  (print msg)
  (ros::ros-info ";; x ~A, y ~A, w ~A, h ~A, a ~A"
		 (send msg :rect :x)
		 (send msg :rect :y)
		 (send msg :rect :width)
		 (send msg :rect :height)
		 (send msg :rect :angle))
  (setq *msg* msg)
  (let ((mrk (instance image_view2::ImageMarker2 :init)))
    (send mrk :type image_view2::ImageMarker2::*POINTS*)
    (send mrk :points (list (instance geometry_msgs::Point :init
				     :x (send msg :rect :x)
				     :y (send msg :rect :y))))
    (send mrk :lifetime (ros::Time 1))
    (send mrk :id 1)
    (send mrk :scale 5.0)
    (ros::publish "image_marker" mrk))
  )

(ros::subscribe "/camshift/result" jsk_recognition_msgs::RotatedRectStamped
		#'color-cb)
(ros::advertise "image_marker" image_view2::ImageMarker2 1)

(warning-message 2 "start main loop~%")
(ros::rate 10)
(do-until-key
 (if *msg*
     (if (> (send *msg* :rect :x) 320)
	 (send *robot* :head :neck-y :joint-angle -5 :relative t)
       (send *robot* :head :neck-y :joint-angle 5 :relative t))
   );;if *msg*
 (ros::spin-once)
 (ros::sleep)
 (send *irtviewer* :draw-objects)
 (x::window-main-one)
 )
(ros::exit)
