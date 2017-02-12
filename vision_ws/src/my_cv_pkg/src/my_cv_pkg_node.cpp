#include <ros/ros.h>
#include <image_transport/image_transport.h>
#include <cv_bridge/cv_bridge.h>
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/features2d/features2d.hpp"

class MyCvPkg
{
  image_transport::Subscriber img_sub_;
  image_transport::ImageTransport it_;

  void imageCallback(const sensor_msgs::ImageConstPtr &msg)
  {
    ROS_INFO("Received image");
    cv::Mat in_img = cv_bridge::toCvCopy(msg, msg->encoding)->image;
    //write just opencv code
    cv::Mat fast_img = in_img.clone();
    int threshold = 0;
    bool nonmax = true;
    std::vector<cv::KeyPoint> keypoints;
    cv::FAST(in_img,keypoints,threshold,nonmax);
    std::vector<cv::KeyPoint>::iterator it_kp = keypoints.begin();
    for(;it_kp!=keypoints.end();++it_kp)
    {
      cv::circle(fast_img,
        cv::Point(it_kp->pt.x,it_kp->pt.y),
        1,cv::Scalar(50,0,255),-1);
      cv::circle(fast_img,
        cv::Point(it_kp->pt.x,it_kp->pt.y),
        8,cv::Scalar(50,0,255));
    }

    cv::imshow("Fast",fast_img);
    cv::waitKey(1);
    //kokomade
  }
public:
  MyCvPkg(ros::NodeHandle nh = ros::NodeHandle()) : it_(nh)
  {
    img_sub_ = it_.subscribe("image",3, &MyCvPkg::imageCallback, this);
    cv::namedWindow("Fast",1);
  }
};

int main(int argc,char **argv)
{
  ros::init(argc, argv, "my_cv_pkg_node");
  MyCvPkg mcp;
  ros::spin();
}
