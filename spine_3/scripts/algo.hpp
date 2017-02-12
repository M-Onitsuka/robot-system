#include <algorithm>
#include <vector>
#include <iostream>
#include "opencv2/opencv.hpp"
#include <cmath>

template <typename T>
T median(std::vector<T>& c)
{
    size_t n = c.size() / 2;
    std::nth_element(c.begin(), c.begin() + n, c.end());
    return c[n];
}

//axis 0:x 1:y
int calc_center (cv::Mat src,int pos,int axis)
{
  double mass = 0,moment = 0;
  if(axis == 0)
  {
    for(int y=0;y<src.rows;y++)
    {
      for(int x=0;x<src.cols&&x!=pos;x++)
      {
        mass += src.at<unsigned char>(y,x)*exp(-pow(x - pos,2)/100);
        moment += x*src.at<unsigned char>(y,x)*exp(-pow(x - pos,2)/100);
      }
    }
    return (int)moment/mass;
  }

  if(axis == 1)
  {
    for(int y=0;y<src.rows&&y!=pos;y++)
    {
      for(int x=0;x<src.cols;x++)
      {
        mass += src.at<unsigned char>(y,x)*exp(-pow(y - pos,2)/100);
        moment += y*(double)src.at<unsigned char>(y,x)*exp(-pow(y - pos,2)/100);
      }
    }
    return (int)moment/mass;
  }

}
