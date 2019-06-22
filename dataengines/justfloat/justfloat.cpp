#include "justfloat.h"
#include <QDebug>
#include <limits>


JustFloat::JustFloat()
{

}

JustFloat::~JustFloat()
{

}


bool JustFloat::ProcessingFrame(char *data, int count)
{
    QVector<float> dd;

    if (count <= 0)
        return false;

    if (count % 4 == 0) {
        for (int i = 0; i < count - 4; i += 4) {
//            double value = datas[i].trimmed().toDouble();
            float value;
            memcpy(&value, data + i, 4);
            dd.append(value);
        }
        frame_datas_list_.append(dd);
        return true;
    }
    return false;
}

void JustFloat::ProcessingDatas(char *data, int count)
{
    frame_datas_list_.clear();
    frame_start_index_list_.clear();
    frame_is_valid_list_.clear();
    frame_end_index_list_.clear();

    int begin = 0;
    for (int i = 3; i < count; i++) {
        char *data_ptr = data + i - 3;
        int d;
        memcpy(&d, data_ptr, 4);
        if (d == static_cast<int>(0x7F800000)) {
            bool frame_is_valid = ProcessingFrame(data + begin, (i - begin) + 1);
            frame_start_index_list_.append(begin);
            frame_end_index_list_.append(i);
            frame_is_valid_list_.append(frame_is_valid);
            begin = i+1;
        }
    }
}


