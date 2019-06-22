#include "RawData.h"
#include <QDebug>
#include <limits>


RawData::RawData()
{

}

RawData::~RawData()
{

}


void RawData::ProcessingDatas(char *data, int count)
{
    frame_datas_list_.clear();
    frame_start_index_list_.clear();
    frame_is_valid_list_.clear();
    frame_end_index_list_.clear();

    frame_start_index_list_.append(count-1);
    frame_end_index_list_.append(count-1);
    frame_is_valid_list_.append(false);

}
