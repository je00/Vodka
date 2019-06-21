#include "firewater.h"
#include <QDebug>
#include <limits>


FireWater::FireWater()
{

}

FireWater::~FireWater()
{

}


bool FireWater::ProcessingFrame(char *data, int count)
{
    QVector<float> dd;

    QString data_string = QString::fromLocal8Bit(data, count).trimmed();

    QList<QString> nameNdata = data_string.split(':');

    if (nameNdata.size() == 2) {
        QString name =  nameNdata[0].trimmed();
        QList<QString> datas = nameNdata[1].split(',');
        for (int i = 0; i < datas.length(); i++) {
            float value = datas[i].trimmed().toFloat();
            dd.append(value);
        }
        frame_datas_list_.append(dd);
        return true;
    }
    return false;
}


void FireWater::ProcessingDatas(char *data, int count)
{
    frame_datas_list_.clear();
    frame_start_index_list_.clear();
    frame_end_index_list_.clear();

    int begin = 0;
    for (int i = 0; i < count; i++) {
        if (data[i] == '\n') {
            if (ProcessingFrame(data + begin, (i - begin) + 1)) {
                frame_start_index_list_.append(begin);
                frame_end_index_list_.append(i);
            }
            begin = i+1;
        }
    }
}
