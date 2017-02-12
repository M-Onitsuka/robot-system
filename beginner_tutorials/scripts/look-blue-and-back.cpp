#include <ros/ros.h>
#include <image_transport/image_transport.h>
#include <cv_bridge/cv_bridge.h>
#include "geometry_msgs/Twist.h"
#include "opencv2/highgui/highgui.hpp"
#include "move_base_msgs/MoveBaseAction.h"
#include <math.h>
#include <actionlib/client/simple_action_client.h> //Cmakeに追加するのをわすれないこと

class LookBlue
{
  image_transport::Subscriber img_sub_;
  image_transport::ImageTransport it_;
  ros::Publisher vel;
  int blueFound;

  void imageCallback(const sensor_msgs::ImageConstPtr &msg)
  {
    //ROS_INFO("Received image");
    cv::Mat in_img = cv_bridge::toCvCopy(msg,msg->encoding)->image;
    //kokokara
    cv::Mat buf = in_img.clone();
    cv::Mat bin(buf.rows,buf.cols,CV_8UC1);
    int cnt = 0;
    for(int y = 0; y < buf.rows; y++)
    {
      for(int x = 0; x < buf.cols; x++)
      {
        if
        (
            buf.at<cv::Vec3b>(y,x)[2] <= 50 &&
            buf.at<cv::Vec3b>(y,x)[1] <= 50 &&
            buf.at<cv::Vec3b>(y,x)[0] > 50
        )
        {
          bin.at<uchar>(y,x) = 255;
          cnt++;
        }else{
          bin.at<uchar>(y,x) = 0;
        }
      }
    }
    //std::vector<cv::Vec3f> circles;
    //cv::HoughCircles(bin,circles,CV_HOUGH_GRADIENT,2,bin.rows,200,100);
    if(cnt > 4000)
    {
      ROS_INFO("this is blue object");
      blueFound = 1;
      actionlib::SimpleActionClient<move_base_msgs::MoveBaseAction> clt("move_base",true);
      ROS_INFO("wait-for-server");
      clt.waitForServer();
      ROS_INFO("let's go to the special position!");

      move_base_msgs::MoveBaseGoal goal; //pythonとcppではMoveBaseActionGoalにしちゃダメ
      goal.target_pose.header.stamp = ros::Time::now();
      goal.target_pose.header.frame_id = "/map";
      goal.target_pose.pose.position.x = 3.5;
      goal.target_pose.pose.position.y = 3.5;
      goal.target_pose.pose.orientation.z = sin(M_PI/4);
      goal.target_pose.pose.orientation.w = cos(M_PI/4);

      clt.sendGoal(goal);
    }

    cv::imshow("extract",bin);
    cv::waitKey(1);
    //kokomade
  }
public:
  LookBlue(ros::NodeHandle nh = ros::NodeHandle())
    : it_(nh),vel(nh.advertise<geometry_msgs::Twist>("cmd_vel",1000))
    ,blueFound(0)
  {
    img_sub_ = it_.subscribe("/camera/rgb/image_raw",3,&LookBlue::imageCallback,this);
    cv::namedWindow("extract",1);
  }

  void commandPublisher(void)
  {
    if(blueFound==0)
    {
      geometry_msgs::Twist cmd;
      cmd.angular.x = 0;
      cmd.angular.y = 0;
      cmd.angular.z = 1;
      vel.publish(cmd);
    }
  }
};

int main(int argc,char **argv)
{
  ros::init(argc,argv,"color_extract_node");
  LookBlue lb;
  ros::Rate loop_rate(10);
  while(1)
  {
      lb.commandPublisher();
      ros::spinOnce();
      if(cv::waitKey(1) == 27)
      {
        break;
      }
      loop_rate.sleep();
  }
}
