#!/usr/bin/env roseus
(load "spine-3-interface.l")
(ros::load-ros-manifest "roseus")
(setq *ri* (instance spine-3-interface :init))
(send *ri* :angle-vector #f(0 15))
(send *ri* :wait-interpolation)

(defun shoot-cb (msg)
  (setq pitch (send msg :pos :y))
  (setq yaw (send msg :pos :z))
  (send *ri* :angle-vector #f(pitch yaw))
  )

(ros::subscribe *topic-name* spine_3::Send_py_data #'shoot-cb)
(ros::rate 5)
(do-until-key
  (ros::spin-once)
  (ros::sleep)
)
