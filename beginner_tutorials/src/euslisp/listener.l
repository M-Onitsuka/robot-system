#!/usr/bin/env roseus
;;実行可能な環境
;;test1-pc:~$ roseus 等を要求

(ros::load-ros-manifest "roseus")
;;roseusのmanifest.lを読み，依存ファイルを全て加える
(ros::roseus "listener" :anonymous t)
;;nodeに名前をつける
;;:anonymaous t はこのnodeに固有の名前をつけて複数のlistener.lが走れるようにしている

(defun string-cb (msg) (print (list 'cb (send msg :data))))
(ros::subscribe "chatter" std_msgs::string #'string-cb)

;;(ros::subscribe "topic_name" msg_type #'call_back_function)
;;topic_nameから渡されたmsg_type型のものがcall_back_functionの引数になる

;;lmbda function
;(ros::subscribe "chatter" std_msgs::string
;		#'(lambda (msg) (ros::ros-info
;				 (format nil "I heard ~A" (send msg :data)))))

;;method call
;; (defclass string-cb-class
;;   :super propertied-object
;;   :slots ())
;; (defmethod string-cb-class
;;   (:init nil
;;    ;;(ros::subscribe "chatter" std_msgs::string #'send self :string-cb)
;;    (ros::subscribe "chatter" std_msgs::string
;; 		   #'(lambda (msg) (format t "yahoo ~A~%" (send msg :data)))))
;;    (:string-cb (msg) (print (list 'cb (send msg :data))))
;;    ))
;; (setq m (instance string-cb-class :init))

(ros::rate 100)
(do-until-key
  (ros::sleep)
  (ros::spin-once))
(exit)