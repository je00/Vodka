#include "rawdata.h"

RawData::RawData()
{
    frame_list_.append(Frame());
    frame_ = &frame_list_[0];
}

RawData::~RawData()
{

}


void RawData::ProcessingDatas(char *data, int count)
{
    // 将所有数据包含为一帧，is_valid_为false，表示这不是一个采样数据包、也不是一个图片数据包
    frame_->start_index_ = 0;
    frame_->end_index_ = count-1;
    frame_->is_valid_ = false;
    frame_->image_size_ = 0;
}
