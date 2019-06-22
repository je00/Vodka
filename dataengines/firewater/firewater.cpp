#include "firewater.h"
#include <QDebug>
#include <limits>


FireWater::FireWater()
{

}

FireWater::~FireWater()
{

}

void FireWater::ProcessingDatas(char *data, int count)
{
    frame_datas_list_.clear();
    frame_start_index_list_.clear();
    frame_is_valid_list_.clear();
    frame_end_index_list_.clear();

    int begin = 0;
    for (int i = 0; i < count; i++) {
        if (data[i] == '\n') {
            bool frame_is_valid = false;
            char *tmp_data = data + begin;
            int tmp_count = i - begin + 1;
            QString data_string = QString::fromLocal8Bit(tmp_data , tmp_count);
            QList<QString> nameNdata = data_string.split(':');
            if (nameNdata.size() >= 2) {
                if (nameNdata.size() > 2) {
                    begin += tmp_count - nameNdata[nameNdata.size() - 1].length() - 2;
                }
                QVector<float> dd;
                QString name =  nameNdata[nameNdata.size()-2].trimmed();
                QList<QString> datas = nameNdata[nameNdata.size()-1].trimmed().split(',');
                for (int i = 0; i < datas.length(); i++) {
                    float value = datas[i].trimmed().toFloat();
                    dd.append(value);
                }
                frame_datas_list_.append(dd);
                frame_is_valid = true;
            }
            frame_is_valid_list_.append(frame_is_valid);
            frame_start_index_list_.append(begin);
            frame_end_index_list_.append(i);
            begin = i+1;
        }
    }
}
