#!/usr/bin/env roseus

(ros::load-ros-manifest "roseus")
(ros::roseus "test") ;;node init
(setq *tfl* (instance ros::transform-listener :init))

(load "irteus/demo/sample-robot-model.l")
(setq *robot* (instance sample-robot :init))
(setq *camera-coords* (send *robot* :camera "left-camera"))
(send *camera-coords* :rotate -pi/2 :z)
(setq *target* (make-cube 100 100 100))
(objects (list *robot* *target*))

(warning-message 2 "start main loop~%")
(ros::rate 10)
(do-until-key
 (setq c (send *tfl* :lookup-transform "head_camera" "8x6chessboard" (ros::time 0)))
 (ros::ros-info ";; target location ~A" c)
 (when c
   (send *target* :locate (send *camera-coords* :transforom-vector
				(send c :worldpos)) :world)
   (setq r (send *robot* :rarm :inverse-kinematics *target* :rotaion-axis nil))
   (unless r
     ;; (send *robot* :rarm :inverse-kinematics *target*
     ;; 	           :rotation-axis nil
     ;; 		   :revert-if-fail nil)
     )
   );;when c
 (ros::spin-once)
 (ros::sleep)
 (send *irtviewer* :draw-objects)
 (x::window-main-one)
)

