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
    frame_image_size_list_.clear();

    int begin = 0, end = 0;
    for (int i = 0; i < count; i++) {
        if (data[i] == '\n') {
            end = i;
            bool frame_is_valid = false;
            char *tmp_data = data + begin;
            int tmp_count = i - begin + 1;
            QString data_string = QString::fromLocal8Bit(tmp_data , tmp_count);
            QList<QString> name_ndata = data_string.split(':');
            int image_size = 0;
            if (name_ndata.size() >= 2) {
                if (name_ndata.size() > 2) {
                    begin += tmp_count - name_ndata[name_ndata.size() - 1].length() - 2;
                }
                QVector<float> dd;
                QString name =  name_ndata[name_ndata.size()-2].trimmed();
                QList<QString> datas = name_ndata[name_ndata.size()-1].trimmed().split(',');
                if (name == "image") {
                    if (datas.length() != 5)
                        break;
                    int image_id = datas[0].toInt();
                    image_size =datas[1].toInt();
                    int image_width = datas[2].toInt();
                    int image_height = datas[3].toInt();
                    RawImage::Format image_format = static_cast<RawImage::Format>(datas[4].toInt());
                    if ((count - (i + 1)) < image_size)
                        return;
                    if (image_id > (image_list_.length() - 1)) {
                        image_count_mutation_count_++;
                        if (image_id < 6 || image_count_mutation_count_ >= 6) {
                            image_count_mutation_count_ = 0;
                            while (image_list_.length() < image_id + 1) {
                                image_list_.append(new RawImage());
                                image_is_updated_list_.append(true);
                            }
                        }
                    }
                    if (image_id < image_list_.length()) {
                        image_list_[image_id]->set((uchar*)data + i + 1, image_size,
                                                   image_width, image_height,
                                                   image_format);
                        image_is_updated_list_[image_id] = true;
                    }
                    end = i + image_size;
                    i = end;
                    frame_is_valid = true;
                } else {
                    for (int i = 0; i < datas.length(); i++) {
                        float value = datas[i].trimmed().toFloat();
                        dd.append(value);
                    }
                    frame_datas_list_.append(dd);
                }
                frame_is_valid = true;
            }
            frame_is_valid_list_.append(frame_is_valid);
            frame_start_index_list_.append(begin);
            frame_end_index_list_.append(end);
            frame_image_size_list_.append(image_size);
            begin = i+1;
        }
    }
}
