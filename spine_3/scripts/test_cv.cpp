#include <ros/ros.h>
#include <std_msgs/String.h>
#include "spine_3/center_pos.h"
#include <opencv2/opencv.hpp>
#include <iostream>
#include "extraction.hpp"
#include "algo.hpp"


#define DISPLAY_MODE 0
#define COUNT_MODE 1

int main(int argc,char* argv[])
{
  cv::Mat frame,buf;
  cv::Mat dst,d_red,d_green;
  cv::Mat hsv;
  cv::Mat ones,gray,kernel;
  int count = 0,flag = DISPLAY_MODE;
  int cent_x=0,cent_y=0;
  int hmin_g=0,hmax_g=0,smin_g=0,smax_g=0,vmin_g=0,vmax_g=0;
  int hmin_r=0,hmax_r=0,smin_r=0,smax_r=0,vmin_r=0,vmax_r=0;
  std::vector<int> data_x,data_y;

  cv::VideoCapture capture(0);
  if(!capture.isOpened())
  {
    std::cout << "ERROR" << std::endl;
    return -1;
  }

  capture >> frame;
  ones = cv::Mat::ones(frame.rows,frame.cols,CV_8UC1);

  ros::init(argc,argv,"detect_center");
  ros::NodeHandle n;
  ros::Publisher center_pos_pub = n.advertise<spine_3::center_pos>("center_pos",1000);
  ros::Rate loop_rate(10);

  while(1)
  {

    //生データ
    capture >> frame;
    cv::imshow("camera image",frame);

    //ガウシアン
    cv::GaussianBlur(frame,dst,cv::Size(7,7),5,0);
    //cv::imshow("gaussian",dst);

    //hsv
    cv::cvtColor(dst,hsv,CV_BGR2HSV);
    //cv::imshow("hsv_window",hsv);

    //緑抽出
    d_green = colorExtraction(hsv,hmin_g,hmax_g,smin_g,smax_g,vmin_g,vmax_g);
    //d_green = colorExtraction(hsv,hmin_g=55,hmax_g=80,smin_g=80,smax_g=95,vmin_g=40,vmax_g=92);
    cv::imshow("extract_g",d_green);
    trackbar("extract_g",&hmin_g,&hmax_g,&smin_g,&smax_g,&vmin_g,&vmax_g);

    //赤抽出
    d_red = colorExtraction(hsv,hmin_r,hmax_r,smin_r,smax_r,vmin_r,vmax_r);
    //d_red = colorExtraction(hsv,hmin_r=0,hmax_r=10,smin_r=87,smax_r=96,vmin_r=35,vmax_r=65);
    cv::imshow("extract_r",d_red);
    trackbar("extract_r",&hmin_r,&hmax_r,&smin_r,&smax_r,&vmin_r,&vmax_r);
    //統合
    cv::bitwise_or(d_red,d_green,dst,ones);

    cv::cvtColor(dst,buf,CV_HSV2RGB);
    cv::cvtColor(dst,gray,CV_RGB2GRAY);
    cv::threshold(gray,dst,0,255,cv::THRESH_BINARY|cv::THRESH_OTSU);
    //cv::imshow("threshold",dst);

    std::vector<cv::Vec3f> circles;
    cv::HoughCircles(gray,circles,CV_HOUGH_GRADIENT,2,gray.rows,200,100);

    for(size_t i = 0; i<circles.size();i++)
    {
      cv::Point center(cvRound(circles[i][0]),cvRound(circles[i][1]));

      if(flag == DISPLAY_MODE)
      {
        std::cout << '\r' << "x: " << circles[i][0] <<"y: " << circles[i][1] <<std::flush;
      }
      int radius = cvRound(circles[i][2]);
      cv::circle(frame,center,3,cv::Scalar(0,255,0),-1,8,0);
      cv::circle(frame,center,radius,cv::Scalar(0,0,255),3,8,0);
    }
    cv::imshow("gray",gray);
    cv::imshow("circles",frame);

    kernel = cv::Mat::ones(5,5,CV_8UC1);
    cv::morphologyEx(dst,buf,cv::MORPH_CLOSE,kernel);
    cv::imshow("morphology",buf);

    if(cv::waitKey(5) == 'c')
    {
      std::cout << std::endl;
      std::cout << "COUNT MODE" <<std::endl;
      flag = COUNT_MODE;
    }

    if(flag == COUNT_MODE&&circles.size()!=0)
    {
      data_x.push_back(cvRound(circles[0][0]));
      data_y.push_back(cvRound(circles[0][1]));
      count++;
    }

    if(cv::waitKey(5) == 'd')
    {
      std::cout << std::endl;
      std::cout << "DISPLAY MODE" <<std::endl;
      flag = DISPLAY_MODE;
      count = 0;
    }

    spine_3::center_pos center_pos_msg;
    if(count <= 100)
    {
      std::cout << '\r' <<count << std::flush;
    }

    if(count >= 100)
    {
      cent_x = median(data_x);
      cent_y = median(data_y);
      cent_x = calc_center(buf,cent_x,0);
      cent_y = calc_center(buf,cent_y,1);
      center_pos_msg.comment = "this may be center position";
      center_pos_msg.pos.x = cent_x;
      center_pos_msg.pos.y = cent_y;
      center_pos_msg.pos.z = 0;
      center_pos_pub.publish(center_pos_msg);
      ros::spinOnce();

      loop_rate.sleep();
    }

    if((cv::waitKey(5)&255) == 27)
    {
      std::cout << std::endl;
      std::cout << "see you" <<std::endl;
      break;
    }

  }

  capture.release();
  cv::destroyAllWindows();

  return 0;
}
