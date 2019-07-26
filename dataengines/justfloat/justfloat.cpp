#include "justfloat.h"
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

bool JustFloat::ProcessingImage(char *data, int count)
{
    QVector<float> dd;

    if (count <= 0)
        return false;

    if (count == 16) {
        int image_index, image_size;
        memcpy(&image_index, data, 4);
        memcpy(&image_size, data + 4, 4);
        for (int i = 0; i < count - 8; i += 4) {
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
    frame_image_size_list_.clear();

    int begin = 0, end = 0;
    for (int i = 3; i < count; i++) {
        char *data_ptr = data + i - 3;
        int d;
        bool frame_is_valid;

        memcpy(&d, data_ptr, 4);
        if (d != static_cast<int>(0x7F800000))
            continue;

        int image_size = 0;
        if ((i + 4) < count) {
            int d2;
            memcpy(&d2, data + i + 1, 4);

            if (d2 == static_cast<int>(0x7F800000)) {
                // Two consecutive frame endings show that the picture is coming
                i += 4;

                if ((i - begin + 1) == 20) {
                    int image_id;
                    QString format;
                    memcpy(&image_id, data + i - 19, 4);
                    memcpy(&image_size, data + i - 15, 4);
                    format = QString::fromLocal8Bit(data + i - 11, 4);

                    if ((i + image_size) >= count) {
                        // The image has not been fully received yet.
                        return;
                    }
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
                        image_list_[image_id]->set((uchar*)data + i + 1, image_size, "format");
                        image_is_updated_list_[image_id] = true;
                    }
                    end = i + image_size;
                    i = end;
                    frame_is_valid = true;
                }
            } else {
                frame_is_valid = ProcessingFrame(data + begin, (i - begin) + 1);
                end = i;
            }
        } else {
            frame_is_valid = ProcessingFrame(data + begin, (i - begin) + 1);
            end = i;
        }
        frame_is_valid_list_.append(frame_is_valid);
        frame_start_index_list_.append(begin);
        frame_end_index_list_.append(end);
        frame_image_size_list_.append(image_size);
        begin = i+1;

    }
}


