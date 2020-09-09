#include "justfloat.h"
#include <limits>


JustFloat::JustFloat()
{

}

JustFloat::~JustFloat()
{

}


bool JustFloat::ProcessingFrame(char *data, int count, QVector<float> &dd)
{
    if (count <= 0)
        return false;

    if (count % 4 == 0) {
        // 只有数据长度是4的倍数，才是合法的浮点数组
        for (int i = 0; i < count - 4; i += 4) {
            //            double value = datas[i].trimmed().toDouble();
            float value;
            memcpy(&value, data + i, 4);
            dd.append(value);
        }
        return true;
    }
    return false;
}


// 帧结构：小端浮点数组 0x7f800000
void JustFloat::ProcessingDatas(char *data, int count)
{

    frame_list_.clear();


    int begin = 0, end = 0;
    for (int i = 3; i < count; i++) {
        char *data_ptr = data + i - 3;
        int frame_tail_data;
        bool frame_is_valid = false;

        memcpy(&frame_tail_data, data_ptr, 4);
        if (frame_tail_data != static_cast<int>(0x7F800000))
            continue;

        // 已经匹配到帧尾 0x7f800000
        end = i;

        int image_size = 0;
        Frame frame;

        if ((i + 4) < count) {
            int frame_tail_data2;
            memcpy(&frame_tail_data2, data + i + 1, 4);
            if (frame_tail_data2 == static_cast<int>(0x7F800000)) {
                // 匹配到2个连续的0x7f800000，这是个图片前导帧
                i += 4;
                if ((i - begin + 1) != 28) {
                // 5个图片前导帧参数 + 2个帧尾，共7个整型数据，28byte
                // 如果帧长度不等于28byte，说明图片前导帧格式错误
                    break;
                }


                // 获取图片信息
                int image_id;
                int image_width;
                int image_height;
                RawImage::Format image_format;
                memcpy(&image_id, data + i - 27, 4);
                memcpy(&image_size, data + i - 23, 4);
                memcpy(&image_width, data + i - 19, 4);
                memcpy(&image_height, data + i - 15, 4);
                memcpy(&image_format, data + i - 11, 4);
                // !获取图片信息


                if ((i + image_size) >= count) {
                    // 图片长度超过缓冲区长度，可能还没接收完，直接返回，下次再来
                    return;
                }
                if (image_id > (image_channels_.length() - 1)) {
                    // 图片id > 图片通道数量，扩充图片通道
                    // 在扩充图片通道之前，为过滤异常情况，保证发送了6帧大id的图片之后，再进行扩充

                    image_count_mutation_count_++;
                    if (image_id < 6 || image_count_mutation_count_ >= 6) {
                        image_count_mutation_count_ = 0;
                        while (image_channels_.length() < image_id + 1) {
                            image_channels_.append(new RawImage());
                        }
                    }
                }
                if (image_id < image_channels_.length()) {
                    // 图片id合法，把图片数据放到图片通道中
                    image_channels_[image_id]->set((uchar*)data + i + 1, image_size,
                                                   image_width, image_height, image_format);
                }

                // 把图片数据结尾记录为帧尾，图片前导帧+图片数据，构成了一个图片数据包
                end = i + image_size;
                i = end;
                frame_is_valid = true;  // 至此，可以确定这是一个合法的图片数据包
            } else {
                // 解析浮点数组，将其转换为采样数据
                frame_is_valid = ProcessingFrame(data + begin, (i - begin) + 1, frame.datas_);
            }
        } else {
            // 解析浮点数组，将其转换为采样数据
            frame_is_valid = ProcessingFrame(data + begin, (i - begin) + 1, frame.datas_);
        }

        // 记录帧 是否合法，开始位置，结束位置，图片尺寸（如果为0，标识其不是图片数据包）
        frame.is_valid_ = frame_is_valid;
        frame.start_index_ = begin;
        frame.end_index_ = end;
        frame.image_size_ = image_size;
        frame_list_.append(frame);
        // !记录帧

        begin = i+1;

    }
}


