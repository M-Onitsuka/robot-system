;;
(require :robot-interface "package://pr2eus/robot-interface.l")

(defclass spine-3-robot
  :super robot-model
  :slots (j1 j2))
(defmethod spine-3-robot
  (:init
   (&rest args)
   (let (l1 l2 l3)
     ;; link
     (setq l1 (instance bodyset-link :init (make-cascoords) :bodies (list (make-cube 10 10 10)) :name :link1)
	   l2 (instance bodyset-link :init (make-cascoords) :bodies (list (make-cube 10 10 10)) :name :link2)
	   l3 (instance bodyset-link :init (make-cascoords) :bodies (list (make-cube 10 10 10)) :name :link3)
	   )
	   ;;l4 (instance bodyset-link :init (make-cascoords) :bodies (list (make-cube 10 10 10)) :name :link4))
     ;; joint
     (setq j1 (instance rotational-joint :init :parent-link l1 :child-link l2 :name "joint1" :min -35 :max 35)
	   j2 (instance rotational-joint :init :parent-link l2 :child-link l3 :name "joint2" :min 0 :max 20)
	   ;;j3 (instance rotational-joint :init :parent-link l3 :child-link l4 :name "joint3" :min -300 :max 300))
	   )
     ;;
     (setq links (list l1 l2 l3))
     (setq joint-list (list j1 j2))
     (send self :init-ending)
     self))
  (:joint1 (&rest args) (forward-message-to j1 args))
  (:joint2 (&rest args) (forward-message-to j2 args))
  ;;(:joint3 (&rest args) (forward-message-to j3 args))
  )

(defclass spine-3-interface
  :super robot-interface
  :slots ())
(defmethod spine-3-interface
  (:init (&rest args)
	 (send-super :init :robot spine-3-robot))
  (:default-controller
   ()
   (list
    (list
     (cons :controller-action "fullbody_controller/follow_joint_trajectory")
     (cons :controller-state "fullbody_controller/state")
     (cons :action-type control_msgs::FollowJointTrajectoryAction)
     (cons :joint-names (mapcar #'(lambda (n) (if (symbolp n) (symbol-name n) n)) (send-all (send robot :joint-list) :name))))))
  );

;;
#|
$ roseus spine-3-interface.l
(setq *ri* (instance spine-3-interface :init))
(send *ri* :state :potentio-vector)
(send *ri* :angle-vector #f(0 10 20) 10000)
(send *ri* :wait-interpolation)
|#
