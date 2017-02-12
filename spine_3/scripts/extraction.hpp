cv::Mat colorExtraction(cv::Mat src,
  int ch1Lower, int ch1Upper,
  int ch2Lower, int ch2Upper,
  int ch3Lower, int ch3Upper
  )
{
  int k;
  int lower[3];
  int upper[3];
  cv::Mat dst_[3];
  cv::Mat dst(src.rows,src.cols,CV_8UC1);
  cv::Mat buf(src.rows,src.cols,CV_8UC1);
  cv::Mat buf_(src.rows,src.cols,CV_8UC1);

  for(k = 0;k<3;k++)
  {
    dst_[k] = cv::Mat::zeros(src.rows,src.cols,CV_8UC1);
  }

  lower[0] = ch1Lower;
  lower[1] = ch2Lower;
  lower[2] = ch3Lower;

  upper[0] = ch1Upper;
  upper[1] = ch2Upper;
  upper[2] = ch3Upper;

  for(int y = 0; y < src.rows; y++)
  {
    for(int x = 0; x < src.cols; x++)
    {
      for(k = 0;k < 3;k++)
      {

        if(lower[k] <= upper[k])
        {
          if((lower[k]<=src.at<cv::Vec3b>(y,x)[k])&&(src.at<cv::Vec3b>(y,x)[0]<=upper[k]))
          {
            dst_[k].at<uchar>(y,x) = 255;
          }else{
            dst_[k].at<uchar>(y,x) = 0;
          }
        }else{
          if((src.at<cv::Vec3b>(y,x)[k]<=lower[k])||(upper[k]<=src.at<cv::Vec3b>(y,x)[k]))
          {
            dst_[k].at<uchar>(y,x) = 255;
          }else{
            dst_[k].at<uchar>(y,x) = 0;
          }
        }

      }
    }
  }

  cv::bitwise_and(src,src,buf,dst_[0]);
  cv::bitwise_and(buf,buf,buf_,dst_[1]);
  cv::bitwise_and(buf_,buf_,dst,dst_[2]);
  //cv::bitwise_and(src,src,buf,dst_[0]);
  return dst;
}

void trackbar(const std::string& winname,
  int *hmin, int *hmax,
  int *smin, int *smax,
  int *vmin, int *vmax)
{
  cv::createTrackbar("hmin",winname,0,180,NULL,NULL);
  *hmin = cv::getTrackbarPos("hmin",winname);
  cv::createTrackbar("hmax",winname,0,180,NULL,NULL);
  *hmax = cv::getTrackbarPos("hmax",winname);
  cv::createTrackbar("smin",winname,0,255,NULL,NULL);
  *smin = cv::getTrackbarPos("smin",winname);
  cv::createTrackbar("smax",winname,0,255,NULL,NULL);
  *smax = cv::getTrackbarPos("smax",winname);
  cv::createTrackbar("vmin",winname,0,255,NULL,NULL);
  *vmin = cv::getTrackbarPos("vmin",winname);
  cv::createTrackbar("vmax",winname,0,255,NULL,NULL);
  *vmax= cv::getTrackbarPos("vmax",winname);
}
