#!/usr/bin/env roseus
;;実行可能な環境 $roseusを要求
(ros::roseus "test_publish_marker")
;;このfileのnode名を"test_publisher_marker"に

(defvar *pub-cylinder-topic* "/cylinder_marker")
(defvar *pub-cube-topic* "/cube_marker")
(defvar *pub-sphere-topic* "/sphere_marker")
(defvar *pub-line-topic* "/line_marker")
(defvar *pub-face-topic* "/face_marker")
(defvar *pub-all-topic* "/all_marker_array")
;;topic名の設定

(setq *tfb* (instance ros::transform-broadcaster :init))
;;tfのbroadcasterを使う(tfってなんだか調べても良くわかっていない)

(defun test-pub ()
  (make-irtviewer);;irtviewerの生成
  (ros::rate 10);;10hz
  ;;局所変数を作る
  (let ((cyl (make-cylinder 100 200)) ;;円筒
	(cb (make-cube 100 100 200 :pos (float-vector 200 0 0))) ;;箱
    	(sp (make-sphere 100 :pos (float-vector -200 0 0))) ;;球
        (l (list #f(100 0 200) ;;線_ここでは五芒星を書いている
		 #f(-81 59 200)
		 #f(31 -95 200)
		 #f(31 95 200)
		 #f(-81 -59 200)
		 #f(100 0 200)))
        (f (make-face-from-vertices ;;面_ここでは五角形を書いている
	    (list (list #f(100 0 -200)) 
		  (list #f(31 95 -200)) 
		  (list #f(-81 59 -200)) 
		  (list #f(-81 -59 -200)) 
		  (list #f(31 -95 -200)) 
		  (list #f(100 0 -200)))))
	)
    (send cyl :translate (float-vector 0 0 -100)) ;;cylを世界座標系で平行移動
    (objects (list cyl cb sp)) ;;irtviewer上に物体を描画
    (do-until-key
     ;;局所変数
     (let* ((header (instance std_msgs::header :init ;;header
                              :stamp (ros::time-now)
                              :frame_id "/test_id"))
            (cyl-msg (cylinder->marker-msg cyl header)) 
	    ;;cylinder->marker-msgは後述のvisualization_msgs/Markerに対応する型のメッセージを作る関数だと思われる．
	    (cb-msg (cube->marker-msg cb header
				      :color (float-vector 0 1 0) :alpha 0.5))
	    ;;rgbaの設定
	    ;;多分デフォルト値が:color #f(1 0 0) :alpha 1
	    ;;alphaは透明度
	    (sp-msg (sphere->marker-msg sp header
					:color (float-vector 0 0 1) :alpha 0.5))
            (l-msg (line->marker-msg l header
                                     :color (float-vector 1 1 0) :alpha 0.5))
            (f-msg (faces->marker-msg (list f) header
                                      :color (float-vector 0 1 1)))
	    (all-msg (instance visualization_msgs::MarkerArray :init))
	    ;;上のobjectsを全部入れるためのMarkerArrayのmsgを作る
	    )
       (send *tfb* :send-transform (make-coords) "/tmp" "/test_id")
       ;;transform-broadcastする
       ;;fixed frameをtmpにしているんだと思う

       ;; for single msg
       (ros::publish *pub-cylinder-topic* cyl-msg)
       (ros::publish *pub-cube-topic* cb-msg)
       (ros::publish *pub-sphere-topic* sp-msg)
       (ros::publish *pub-line-topic* l-msg)
       (ros::publish *pub-face-topic* f-msg)
       ;;各図形をpublish

       ;; for array msg
       ;; you shold set up namespace (:ns ) or id (:id) for marker array
       ;;array msgを使うためにはmsg名がかぶらないように名前空間を作ってあげる必要がある
       (send cyl-msg :ns "test_cyl")
       (send cb-msg :ns "test_cb")
       (send sp-msg :ns "test_sp")
       (send l-msg :ns "test_l")
       (send f-msg :ns "test_f")
       ;;all-msgに上のmsgを入れていく
       (send all-msg :markers (list cyl-msg cb-msg sp-msg l-msg f-msg))
       ;;all-msgをpublish
       (ros::publish *pub-all-topic* all-msg)

       (send cyl :rotate (deg2rad 1) :x)
       (send cb :rotate (deg2rad 1) :x)
       ;;cylとcbを回転

       ;;物体をirtviewer上に描写
       (send *irtviewer* :draw-objects)
       (x::window-main-one)
       (ros::spin-once)
       (ros::sleep)
       ;;0.2sec - 今回のループにかかった時間だけ待つ，と考えている
       (print header)
       ))))

;;rvizに基本的な図形を送るvisualization_msgsをadvertiseする
(ros::advertise *pub-cylinder-topic* visualization_msgs::Marker 5)
(ros::advertise *pub-cube-topic* visualization_msgs::Marker 5)
(ros::advertise *pub-sphere-topic* visualization_msgs::Marker 5)
(ros::advertise *pub-line-topic* visualization_msgs::Marker 5)
(ros::advertise *pub-face-topic* visualization_msgs::Marker 5)
(ros::advertise *pub-all-topic* visualization_msgs::MarkerArray 5)
(test-pub)
