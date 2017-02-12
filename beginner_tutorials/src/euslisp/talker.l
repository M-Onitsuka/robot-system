#!/usr/bin/env roseus

(ros::load-ros-manifest "roseus")
(ros::roseus "talker")
;;nodeをinitすると共にnode名をtalkerにしている
;;listener.lも参照
(ros::advertise "chatter" std_msgs::string 1)
;;chatterというtopicにstd_msgs::stringというメッセージの型のものを送ることをmasterに宣言
(ros::rate 10)
;;10hz
(while (ros::ok)
#|
ros::okでは次のようなときにnilを返す
-SIGINTsignal(つまりCtrl-C)を受け取った時
-同じ名前のノードができてネットワークから外された時
-どこかでros::shutdownが呼ばれた時
-全てのros::NodeHandlesが破棄された時
|#
  (setq msg (instance std_msgs::string :init));;msg型のオブジェクトをinstanciate
  (send msg :data (format nil "hello world ~a" (send (ros::time-now) :sec-nsec)))
  ;;(send msg :data "hello world ~a" (send (ros::time-now) :sec-nsec))←こいつはなんでダメ？
  ;;多分ros::_data . ""に中身をぶち込んでいる
  ;;ros::time-nowを~aに
  ;;format nilで標準出力ではなく返り値に文字列として出力
  (ros::ros-info "msg [~A]" (send msg :data))
  (ros::publish "chatter" msg)
  ;;topic名chatterにmsgをpublish
  (ros::sleep)
  ;;多分(0.1秒-動作時間)待つ
  )
(exit)
